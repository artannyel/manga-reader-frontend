import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_reader/features/auth/domain/entities/user.dart';
import 'package:manga_reader/features/auth/domain/repositories/auth_repository.dart';
import 'package:manga_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:manga_reader/features/auth/presentation/providers/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  Future<User> Function({required String email, required String password})? loginHandler;
  Future<User> Function({required String name, required String email, required String password, required String passwordConfirmation})? registerHandler;
  Future<void> Function()? logoutHandler;
  Future<String?> Function()? getTokenHandler;
  Future<void> Function()? deleteTokenHandler;
  Future<User?> Function()? getSavedUserHandler;

  @override
  Future<User> login({required String email, required String password}) {
    if (loginHandler != null) {
      return loginHandler!(email: email, password: password);
    }
    throw UnimplementedError('loginHandler not set');
  }

  @override
  Future<User> register({required String name, required String email, required String password, required String passwordConfirmation}) {
    if (registerHandler != null) {
      return registerHandler!(name: name, email: email, password: password, passwordConfirmation: passwordConfirmation);
    }
    throw UnimplementedError('registerHandler not set');
  }

  @override
  Future<void> logout() {
    if (logoutHandler != null) {
      return logoutHandler!();
    }
    return Future.value();
  }

  @override
  Future<String?> getToken() {
    if (getTokenHandler != null) {
      return getTokenHandler!();
    }
    return Future.value(null);
  }

  @override
  Future<void> deleteToken() {
    if (deleteTokenHandler != null) {
      return deleteTokenHandler!();
    }
    return Future.value();
  }

  @override
  Future<User?> getSavedUser() {
    if (getSavedUserHandler != null) {
      return getSavedUserHandler!();
    }
    return Future.value(null);
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthNotifier Tests -', () {
    test('Initial state of AuthNotifier is AuthInitial synchronously', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(authProvider);
      expect(state, isA<AuthInitial>());

      // Wait for any async side effects to finish before disposal
      await pumpEventQueue();
    });

    test('Initial state transitions to AuthUnauthenticated if no credentials in secure storage', () async {
      mockAuthRepository.getSavedUserHandler = () => Future.value(null);
      mockAuthRepository.getTokenHandler = () => Future.value(null);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await pumpEventQueue(); // Let checkAuthStatus complete

      final state = container.read(authProvider);
      expect(state, isA<AuthUnauthenticated>());
    });

    test('Initial state transitions to AuthAuthenticated if credentials exist in secure storage', () async {
      const testUser = User(id: 1, name: 'Test User', email: 'test@example.com');
      mockAuthRepository.getSavedUserHandler = () => Future.value(testUser);
      mockAuthRepository.getTokenHandler = () => Future.value('some_token');

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await pumpEventQueue(); // Let checkAuthStatus complete

      final state = container.read(authProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.id, 1);
      expect(state.user.name, 'Test User');
      expect(state.user.email, 'test@example.com');
    });

    test('login successfully changes state to AuthLoading and then AuthAuthenticated', () async {
      const testUser = User(id: 1, name: 'Test User', email: 'test@example.com');
      mockAuthRepository.getSavedUserHandler = () => Future.value(null);
      mockAuthRepository.getTokenHandler = () => Future.value(null);
      mockAuthRepository.loginHandler = ({required email, required password}) => Future.value(testUser);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // Settle initial status check
      container.read(authProvider);
      await pumpEventQueue();

      final states = <AuthState>[];
      container.listen<AuthState>(
        authProvider,
        (previous, next) => states.add(next),
        fireImmediately: false,
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'password');

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      expect((states[1] as AuthAuthenticated).user.id, 1);
      expect((states[1] as AuthAuthenticated).user.name, 'Test User');
    });

    test('login with bad credentials changes state to AuthLoading and then AuthError', () async {
      mockAuthRepository.getSavedUserHandler = () => Future.value(null);
      mockAuthRepository.getTokenHandler = () => Future.value(null);
      mockAuthRepository.loginHandler = ({required email, required password}) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
        );
      };

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // Settle initial status check
      container.read(authProvider);
      await pumpEventQueue();

      final states = <AuthState>[];
      container.listen<AuthState>(
        authProvider,
        (previous, next) => states.add(next),
        fireImmediately: false,
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.login(email: 'test@example.com', password: 'wrong_password');

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());
      expect((states[1] as AuthError).message, 'E-mail ou senha incorretos.');
    });

    test('register successfully changes state to AuthLoading and then AuthAuthenticated', () async {
      const testUser = User(id: 2, name: 'New User', email: 'new@example.com');
      mockAuthRepository.getSavedUserHandler = () => Future.value(null);
      mockAuthRepository.getTokenHandler = () => Future.value(null);
      mockAuthRepository.registerHandler = ({required name, required email, required password, required passwordConfirmation}) => Future.value(testUser);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // Settle initial status check
      container.read(authProvider);
      await pumpEventQueue();

      final states = <AuthState>[];
      container.listen<AuthState>(
        authProvider,
        (previous, next) => states.add(next),
        fireImmediately: false,
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.register(name: 'New User', email: 'new@example.com', password: 'password', passwordConfirmation: 'password');

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      expect((states[1] as AuthAuthenticated).user.id, 2);
      expect((states[1] as AuthAuthenticated).user.name, 'New User');
    });

    test('logout successfully clears state and transitions to AuthUnauthenticated', () async {
      const testUser = User(id: 1, name: 'Test User', email: 'test@example.com');
      mockAuthRepository.getSavedUserHandler = () => Future.value(testUser);
      mockAuthRepository.getTokenHandler = () => Future.value('some_token');
      mockAuthRepository.logoutHandler = () => Future.value();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // Settle initial status check to make it AuthAuthenticated
      container.read(authProvider);
      await pumpEventQueue();
      expect(container.read(authProvider), isA<AuthAuthenticated>());

      final states = <AuthState>[];
      container.listen<AuthState>(
        authProvider,
        (previous, next) => states.add(next),
        fireImmediately: false,
      );

      final notifier = container.read(authProvider.notifier);
      await notifier.logout();

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthUnauthenticated>());
    });
  });
}
