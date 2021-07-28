import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../models/last_move.dart';
import '../models/mark.dart';

const String usersCol = 'users';
const String gamesCol = 'games';

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
          var index =
              fri!.friends.indexWhere((element) => element.uid == user.uid);
          if (index != -1) {
            fri.friends[index].username = newName;
            updateList.add({
              'ref': friendRef,
              'newFriends': AppUser.friendListToJson(fri.friends)
            });
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

  // ###### GAMES:
  Future<DocumentReference<Map<String, dynamic>>> createHostGame(
      String uid, String username) {
    return _firestore.collection(gamesCol).add({
      'hostPlayerUid': uid,
      'hostPlayer': username,
      'created': DateTime.now().toIso8601String(),
      'addedPlayerUid': null,
      'addedPlayer': null,
      'open': true,
      'hostPlayerGoesFirst': Random().nextBool(),
      'gameMarks': json.encode(_convertGameMarksToJson(baseGameMarks)),
    });
  }

  Future<void> joinGame(String docId, String uid, String username) {
    return _firestore.collection(gamesCol).doc(docId).update({
      'addedPlayer': username,
      'addedPlayerUid': uid,
      'open': false,
    });
  }

  Future<String> inviteFriendGame(AppUser user, AppUser friend) async {
    var date = DateTime.now().toIso8601String();

    String gameId = '';

    await _firestore.runTransaction((transaction) async {
      var gameRef = _firestore.collection(gamesCol).doc();
      var userRef = _firestore.collection(usersCol).doc(user.uid);
      var friendRef = _firestore.collection(usersCol).doc(friend.uid);

      transaction.set(gameRef, {
        'hostPlayerUid': user.uid,
        'hostPlayer': user.username,
        'created': date,
        'addedPlayerUid': null,
        'addedPlayer': null,
        'open': false,
        'hostPlayerGoesFirst': Random().nextBool(),
        'gameMarks': json.encode(_convertGameMarksToJson(baseGameMarks)),
      });

      gameId = gameRef.id;

      transaction.update(userRef, {
        "createdGame": {
          'gameId': gameId,
          'inviteeUsername': user.username,
          'created': date,
        }
      });

      transaction.update(friendRef, {
        "invited": FieldValue.arrayUnion([
          {
            'gameId': gameId,
            'inviteeUsername': user.username,
            'created': date,
          }
        ])
      });
    });

    return gameId;
  }

  deleteInvite(AppUser user, String friendUid) {
    deleteGame(user.uid).then((_) async {
      if (user.createdGame != null) {
        await removeInvitedGame(user.createdGame!, friendUid);
      }
    });
  }

  removeInvitedGame(Invited game, String friendUid) async {
    await _firestore.collection(usersCol).doc(friendUid).update({
      "invited": FieldValue.arrayRemove(
        [
          Invited.toJson(
            game,
          )
        ],
      )
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> joinInvitedGame(
      String docId, String uid, String username) async {
    await _firestore.collection(gamesCol).doc(docId).update({
      'addedPlayer': username,
      'addedPlayerUid': uid,
      'open': false,
    });

    return _firestore.collection(gamesCol).doc(docId).get();
  }

  Future<void> leaveGame(String docId, String uid) async {
    var doc = await _firestore.collection(gamesCol).doc(docId).get();

    if (doc.data() == null) return;

    Map<String, Object?> newData = {};

    if (doc.data()!['hostPlayerUid'] == uid) {
      newData['hostPlayer'] = doc.data()!['addedPlayer'];
      newData['hostPlayerUid'] = doc.data()!['addedPlayerUid'];
    }

    newData['addedPlayer'] = null;
    newData['addedPlayerUid'] = null;
    newData['open'] = true;
    newData['gameMarks'] = json.encode(_convertGameMarksToJson(baseGameMarks));
    newData['lastMove'] = null;

    return _firestore.collection(gamesCol).doc(docId).update(newData);
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
}
