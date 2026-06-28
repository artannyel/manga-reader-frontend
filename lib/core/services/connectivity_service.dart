import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityNotifier() : super(ConnectivityStatus.online) {
    _init();
  }

  void _init() async {
    // Check initial connectivity
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {
      // Default to online on failure
      state = ConnectivityStatus.online;
    }

    // Listen to changes
    _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else {
      state = ConnectivityStatus.online;
    }
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});
