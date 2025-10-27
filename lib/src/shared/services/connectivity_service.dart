import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity service use to check if an app is connected to the internet.
/// Exposes a stream to allow the client perform more on time state changes as connectivity changes.
/// Also exposes a hasConnection getter for one-off on-demand connection checks.
/// Call ConnectivityService.instance.initialise() to get the service up and running.
/// Service depends on connectivity_plus.
final class ConnectivityService {
  ConnectivityService._();

  bool hasConnection = false;
  final _connectivity = Connectivity();
  static final ConnectivityService instance = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _controller.stream;

  void initialise() {
    _connectivity.onConnectivityChanged.listen(_connectivityEventOnChanged);

    _checkConnection();
  }

  void _connectivityEventOnChanged(List<ConnectivityResult>? result) {
    _checkConnection();
  }

  void _checkConnection() async {
    final previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      _controller.add(hasConnection);
    }
  }

  void dispose() => _controller.close();
}
