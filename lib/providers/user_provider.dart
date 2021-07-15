import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/fire_service.dart';

class UserProvider with ChangeNotifier {
  final _auth = AuthService();
  final _fire = FireService();

  String _uid = '';
  String _username = '';
  List<AppUser> _friends = [];

  String get uid {
    return _uid;
  }

  String get username {
    return _username;
  }

  List<AppUser> get friends {
    return _friends;
  }

  void updateUsername(String newName) {
    _fire.updateUsername(uid, newName);
    _username = newName;
    notifyListeners();
  }

  Future<bool> createAnonymousUser() async {
    final user = await _auth.signInAnonymously();
    if (user != null) {
      _uid = user.uid;
      _username = user.username;
      _friends = user.friends;

      notifyListeners();
      return true;
    }

    return false;
  }

  setUser(User? user) {
    if (user != null) {
      _uid = user.uid;
    }
  }
}
