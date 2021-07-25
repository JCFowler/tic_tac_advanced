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

  Future<AppUser?> getUserWithUid(String uid) async {
    final result = await _firestore.collection(usersCol).doc(uid).get();

    if (result.data() != null) {
      final friends = result.data()!['friends'] != null
          ? List<AppUser>.from(result.data()!['friends'])
          : <AppUser>[];

      return AppUser(
        uid,
        result.data()!['username'],
        friends,
      );
    }

    return null;
  }

  Future<void> updateUsername(String uid, String newName) async {
    await _firestore.collection(usersCol).doc(uid).set({'username': newName});
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
        .limit(1)
        .get();

    await doc.docs.first.reference.delete();
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
