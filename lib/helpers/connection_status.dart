import 'dart:io';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionStatus {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatus _singleton = ConnectionStatus._internal();
  ConnectionStatus._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionStatus getInstance() => _singleton;

  bool hasConnection = false;

  StreamController connectionChangeController = BehaviorSubject<bool>();

  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  Stream<bool> get stream => connectionChangeController.stream as Stream<bool>;

  void _connectionChange(ConnectivityResult result) {
    checkConnection(result);
  }

  Future<bool> checkConnection(ConnectivityResult connectivityResult) async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (connectivityResult != ConnectivityResult.none &&
          result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
