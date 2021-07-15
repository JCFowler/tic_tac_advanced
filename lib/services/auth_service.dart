import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'fire_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _fireService = FireService();

  getCurrentUser() {
    return _auth.currentUser;
  }

  signOut() {
    return _auth.signOut();
  }

  Future<AppUser?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;

      if (user != null) {
        var oldUser = await _fireService.getUserWithUid(user.uid);
        if (oldUser != null) {
          return oldUser;
        }

        final _random = Random();
        var uniqueUsername = false;
        var username = 'Guest${_random.nextInt(999999)}';

        if (!await _fireService.doesUsernameExist(username)) {
          var cycle = 0; // Fail safe to make sure it doesn't keep going.

          while (!uniqueUsername) {
            username = 'Guest${_random.nextInt(999999)}';

            final exist = await _fireService.doesUsernameExist(username);

            if (!exist) {
              uniqueUsername = true;
            }

            if (cycle > 1) {
              username = 'Guest${_random.nextInt(9999999)}';
              uniqueUsername = true;
              break;
            }
            cycle++;
          }
        }

        await _fireService.createNewUser(user.uid, username);

        return AppUser(user.uid, username, []);
      }
    } catch (error) {
      return null;
    }
  }
}
