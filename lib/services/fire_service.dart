import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

const String usersCol = 'users';
const String gamesCol = 'games';

// Testing
// const String usersCol = 'test_users';
// const String gamesCol = 'test_games';

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
        .where('player2', isNull: true)
        .limit(5)
        .snapshots();
  }

  // ###### GAMES:

  void createHostGame(String username) {
    _firestore.collection(gamesCol).add({
      'username': username,
      'created': DateTime.now().toIso8601String(),
      'player2': null,
    });
  }

  joinGame(String docId, String username) {
    _firestore.collection(gamesCol).doc(docId).set({'player2': username});
  }
}
