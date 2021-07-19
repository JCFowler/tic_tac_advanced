import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/constants.dart';
import '../models/mark.dart';

const String usersCol = 'users';
const String gamesCol = 'games';

// Testing
// const String usersCol = 'test_users';
// const String gamesCol = 'test_games';

Map<String, dynamic> convertToGameMarksToJson(Map<int, Mark> map) {
  Map<String, dynamic> result = {};

  map.forEach((key, value) {
    print(value.toJson());
    result['$key'] = value.toJson();
  });

  return result;
}

Map<int, Mark> convertJsonToGameMarks(String map) {
  Map<int, Mark> result = {};

  final Map<String, dynamic> data = json.decode(map);

  print(data);

  data.forEach((key, value) {
    print(value);
    result[int.parse(key)] =
        Mark(value['number'], Player.values[value['player']]);
  });

  print(result);

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
        .where('name', isEqualTo: username)
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

  Stream<QuerySnapshot<Map<String, dynamic>>> openGamesStream() {
    return _firestore
        .collection(gamesCol)
        .where('open', isEqualTo: true)
        .limit(5)
        .snapshots();
  }

  // ###### GAMES:

  void createHostGame(String uid, String username) {
    _firestore.collection(gamesCol).add({
      'player1uid': uid,
      'player1': username,
      'created': DateTime.now().toIso8601String(),
      'player2uid': null,
      'player2': null,
      'open': true,
      'gameMarks': json.encode(convertToGameMarksToJson(baseGameMarks)),
    });
  }

  joinGame(String docId, String uid, String username) async {
    await _firestore.collection(gamesCol).doc(docId).update({
      'player2': username,
      'player2uid': uid,
      'open': false,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> gameMatchStream(String docId) {
    return _firestore.collection(gamesCol).doc(docId).snapshots();
  }

  addMark(
    String docId,
    String uid,
    String username,
    Map<int, Mark> gameMarks,
    int newMarkPos,
  ) {
    _firestore.collection(gamesCol).doc(docId).update({
      'gameMarks': json.encode(convertToGameMarksToJson(gameMarks)),
      'last': uid,
      'open': false,
    });
  }
}
