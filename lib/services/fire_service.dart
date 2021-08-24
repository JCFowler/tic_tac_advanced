import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_advanced/models/version.dart';

import '../models/app_user.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../models/last_move.dart';
import '../models/mark.dart';

const String usersCol = 'users';
const String gamesCol = 'games';
const String versionCol = 'version';

// Testing
// const String usersCol = 'test_users';
// const String gamesCol = 'test_games';

Map<String, dynamic> _convertGameMarksToJson(Map<int, Mark> map) {
  Map<String, dynamic> result = {};

  map.forEach((key, value) {
    result['$key'] = value.toJson();
  });

  return result;
}

class FireService {
  final _firestore = FirebaseFirestore.instance;

  // ###### USERS:
  Future<void> createNewUser(String uid, String username) async {
    return _firestore.collection(usersCol).doc(uid).set(
      {
        'username': username,
      },
    );
  }

  Future<bool> doesUsernameExist(String username) async {
    final result = await _firestore
        .collection(usersCol)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return result.docs.length == 1;
  }

  Future<AppUser?> findUser(String username) async {
    final result = await _firestore
        .collection(usersCol)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (result.docs.isEmpty) {
      return null;
    } else {
      return AppUser.docToObject(result.docs[0]);
    }
  }

  Future<void> _addingFriend(AppUser friend, String userId) async {
    await _firestore.collection(usersCol).doc(userId).update({
      "friends": FieldValue.arrayUnion(
        [
          {
            'uid': friend.uid,
            'username': friend.username,
          }
        ],
      )
    });
  }

  Future<void> addFriend(AppUser currentUser, AppUser friend) async {
    // Current user adding friend
    await _addingFriend(friend, currentUser.uid);
    // Friend adding current user
    await _addingFriend(currentUser, friend.uid);
  }

  Future<void> _removingFriend(AppUser friend, String userId) async {
    await _firestore.collection(usersCol).doc(userId).update(
      {
        "friends": FieldValue.arrayRemove([AppUser.friendToJson(friend)])
      },
    );
  }

  Future<void> removeFriend(AppUser currentUser, AppUser friend) async {
    // Current user removing friend
    await _removingFriend(friend, currentUser.uid);
    // Friend removing current user
    await _removingFriend(currentUser, friend.uid);
  }

  Stream<AppUser?> userStream(String uid) {
    return _firestore.collection(usersCol).doc(uid).snapshots().map(
      (event) {
        return AppUser.docToObject(event, returnFriends: true);
      },
    );
  }

  Future<AppUser?> getUserWithUid(String uid) async {
    final result = await _firestore.collection(usersCol).doc(uid).get();

    return AppUser.docToObject(result, returnFriends: true);
  }

  Future<void> updateUsername(AppUser user, String newName) async {
    await _firestore.runTransaction((transaction) async {
      var userRef = _firestore.collection(usersCol).doc(user.uid);

      List<Map<String, dynamic>> updateList = [];
      await Future.forEach(user.friends, (AppUser friend) async {
        var friendRef = _firestore.collection(usersCol).doc(friend.uid);
        await transaction.get(friendRef).then((docFriend) {
          var fri = AppUser.docToObject(docFriend, returnFriends: true);
          if (fri != null) {
            var index =
                fri.friends.indexWhere((element) => element.uid == user.uid);
            if (index != -1) {
              fri.friends[index].username = newName;
              updateList.add({
                'ref': friendRef,
                'newFriends': AppUser.friendListToJson(fri.friends)
              });
            }
          }
        });
      });

      transaction.update(userRef, {'username': newName});

      for (var item in updateList) {
        transaction.update(item['ref'], {"friends": item['newFriends']});
      }
    });
  }

  Stream<List<GameModel>> openGamesStream(String uid) {
    var date =
        DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String();

    return _firestore
        .collection(gamesCol)
        .where('open', isEqualTo: true)
        .where('created', isGreaterThan: date)
        .orderBy('created', descending: true)
        .limit(10)
        .snapshots()
        .map((event) {
      List<GameModel> result = [];
      for (var doc in event.docs) {
        if (doc.data()['hostPlayerUid'] != uid) {
          result.add(GameModel.docToObject(doc)!);
        }
      }
      return result;
    });
  }

  Stream<List<GameModel>> openPrivateGameStream(String uid) {
    var date =
        DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String();

    return _firestore
        .collection(gamesCol)
        .where('invitedUid', isEqualTo: uid)
        .where('created', isGreaterThan: date)
        .orderBy('created', descending: true)
        .limit(10)
        .snapshots()
        .map((event) {
      List<GameModel> result =
          event.docs.map((doc) => GameModel.docToObject(doc)!).toList();

      return result;
    });
  }

  Future<String> hostGame(
    String uid,
    String username, {
    String? friendUid,
  }) async {
    var doc = await _firestore.collection(gamesCol).add({
      'hostPlayerUid': uid,
      'hostPlayer': username,
      'created': DateTime.now().toIso8601String(),
      'addedPlayerUid': null,
      'addedPlayer': null,
      'hostPlayerGoesFirst': Random().nextBool(),
      'gameMarks': json.encode(_convertGameMarksToJson(baseGameMarks)),
      'declined': false,
      'open': friendUid == null ? true : false,
      'invitedUid': friendUid,
    });

    return doc.id;
  }

  Future<void> joinGame(String docId, String uid, String username) {
    return _firestore.collection(gamesCol).doc(docId).update({
      'addedPlayer': username,
      'addedPlayerUid': uid,
      'open': false,
      'invitedUid': null,
    });
  }

  declinePrivateGame(String gameId) async {
    await _firestore.collection(gamesCol).doc(gameId).update({
      'declined': true,
      'invitedUid': null,
    });
  }

  Future<void> leaveGame(String docId, String uid, bool autoOpen) async {
    var doc = await _firestore.collection(gamesCol).doc(docId).get();

    if (doc.data() == null) return;

    Map<String, Object?> newData = {};

    if (doc.data()!['hostPlayerUid'] == uid) {
      newData['hostPlayer'] = doc.data()!['addedPlayer'];
      newData['hostPlayerUid'] = doc.data()!['addedPlayerUid'];
    }

    newData['addedPlayer'] = null;
    newData['addedPlayerUid'] = null;
    newData['open'] = autoOpen;
    newData['gameMarks'] = json.encode(_convertGameMarksToJson(baseGameMarks));
    newData['lastMove'] = null;
    newData['created'] = DateTime.now().toIso8601String();

    return _firestore.collection(gamesCol).doc(docId).update(newData);
  }

  Future<void> restartGame(String docId, bool hostPlayerGoesFirst) async {
    await _firestore.collection(gamesCol).doc(docId).update({
      'gameMarks': json.encode(_convertGameMarksToJson(baseGameMarks)),
      'hostRematch': null,
      'addedRematch': null,
      'lastMove': null,
      'hostPlayerGoesFirst': hostPlayerGoesFirst,
    });
  }

  Future<void> deleteGame(String uid) async {
    var doc = await _firestore
        .collection(gamesCol)
        .where('hostPlayerUid', isEqualTo: uid)
        .get();

    for (var d in doc.docs) {
      d.reference.delete();
    }
  }

  Stream<GameModel?> gameMatchStream(String docId) {
    return _firestore
        .collection(gamesCol)
        .doc(docId)
        .snapshots()
        .map((event) => GameModel.docToObject(event));
  }

  addMark(
    String docId,
    String uid,
    String username,
    Map<int, Mark> gameMarks,
    LastMove thisMove,
  ) {
    _firestore.collection(gamesCol).doc(docId).update({
      'gameMarks': json.encode(_convertGameMarksToJson(gameMarks)),
      'lastMove': json.encode(thisMove),
    });
  }

  Future<void> rematch(String docId, bool isHost, bool answer) async {
    return _firestore.collection(gamesCol).doc(docId).update(
      {isHost ? 'hostRematch' : 'addedRematch': answer},
    );
  }

  resetRematch(String docId) {
    _firestore.collection(gamesCol).doc(docId).update(
      {
        'hostRematch': null,
        'addedRematch': null,
      },
    );
  }

  Future<Version?> getVersion({required bool isAndriod}) async {
    final String doc = isAndriod ? 'android' : 'ios';
    final res = await _firestore.collection(versionCol).doc(doc).get();
    if (res.data() == null) return null;

    return Version.toObject(res.data()!);
  }
}
