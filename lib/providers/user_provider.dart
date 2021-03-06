import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/fire_service.dart';

class UserProvider with ChangeNotifier {
  final _auth = AuthService();
  final _fire = FireService();

  String _uid = '';
  String _username = '';
  AppUser? _user;
  final StreamController<List<AppUser>> _friendStream = BehaviorSubject();
  final StreamController<List<Invited>> _invitedStream = BehaviorSubject();

  String get uid {
    return _uid;
  }

  String get username {
    return _username;
  }

  Stream<List<AppUser>> get friendStream {
    return _friendStream.stream;
  }

  Stream<List<Invited>> get invitedStream {
    return _invitedStream.stream;
  }

  AppUser? get user {
    return _user;
  }

  void startUserStream(String userId) {
    _fire.userStream(userId).listen((user) {
      if (user != null) {
        _uid = user.uid;
        _username = user.username;
        _user = user;
        _friendStream.add(user.friends);
        _invitedStream.add(user.invited);

        notifyListeners();
      }
    });
  }

  Future<void> updateUsername(String newName) {
    return _fire
        .updateUsername(user!, newName)
        .then((_) => _username = newName);
  }

  Future<String?> createAnonymousUser() async {
    final user = await _auth.signInAnonymously();
    if (user != null) {
      startUserStream(user.uid);
      return user.uid;
    }

    return null;
  }
}
