import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:manga_reader/core/services/connectivity_service.dart';

class MockConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> mockResults = [ConnectivityResult.wifi];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return mockResults;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  void emit(List<ConnectivityResult> results) {
    mockResults = results;
    _controller.add(results);
  }

  void dispose() {
    _controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
  });

  tearDown(() {
    mockConnectivity.dispose();
  });

  test('ConnectivityNotifier starts online when checkConnectivity returns online result', () async {
    mockConnectivity.mockResults = [ConnectivityResult.wifi];

    final container = ProviderContainer(
      overrides: [
        connectivityProvider.overrideWith((ref) => ConnectivityNotifier(connectivity: mockConnectivity)),
      ],
    );
    addTearDown(container.dispose);

    // Read to initialize
    container.read(connectivityProvider);
    await pumpEventQueue();

    expect(container.read(connectivityProvider), ConnectivityStatus.online);
  });

  test('ConnectivityNotifier starts offline when checkConnectivity returns empty or none', () async {
    mockConnectivity.mockResults = [ConnectivityResult.none];

    final container = ProviderContainer(
      overrides: [
        connectivityProvider.overrideWith((ref) => ConnectivityNotifier(connectivity: mockConnectivity)),
      ],
    );
    addTearDown(container.dispose);

    // Read to initialize
    container.read(connectivityProvider);
    await pumpEventQueue();

    expect(container.read(connectivityProvider), ConnectivityStatus.offline);
  });

  test('ConnectivityNotifier updates state when connectivity shifts', () async {
    mockConnectivity.mockResults = [ConnectivityResult.wifi];

    final container = ProviderContainer(
      overrides: [
        connectivityProvider.overrideWith((ref) => ConnectivityNotifier(connectivity: mockConnectivity)),
      ],
    );
    addTearDown(container.dispose);

    // Read to initialize and wait for subscription to be active
    container.read(connectivityProvider);
    await pumpEventQueue();
    expect(container.read(connectivityProvider), ConnectivityStatus.online);

    // Shift to offline
    mockConnectivity.emit([ConnectivityResult.none]);
    await pumpEventQueue();
    expect(container.read(connectivityProvider), ConnectivityStatus.offline);

    // Shift to mobile data (online)
    mockConnectivity.emit([ConnectivityResult.mobile]);
    await pumpEventQueue();
    expect(container.read(connectivityProvider), ConnectivityStatus.online);

    // Shift to empty list (offline)
    mockConnectivity.emit([]);
    await pumpEventQueue();
    expect(container.read(connectivityProvider), ConnectivityStatus.offline);
  });
}
