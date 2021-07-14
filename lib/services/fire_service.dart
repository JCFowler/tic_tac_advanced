import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class FireService {
  final _firestore = FirebaseFirestore.instance;

  Future<bool> doesUsernameExist(String username) async {
    final result = await _firestore
        .collection('users')
        .where('name', isEqualTo: username)
        .limit(1)
        .get();

    return result.docs.length == 1;
  }

  Future<AppUser?> getUserWithUid(String uid) async {
    final result = await _firestore.collection('users').doc(uid).get();

    if (result.data() != null) {
      final friends = List<AppUser>.from(result.data()!['friends']);

      return AppUser(
        uid,
        result.data()!['username'],
        friends,
      );
    }

    return null;
  }
}
