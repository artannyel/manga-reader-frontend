import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

// Use Case Providers
final Provider<LoginUseCase> loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final Provider<RegisterUseCase> registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

// Auth Notifier Provider
final NotifierProvider<AuthNotifier, AuthState> authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _registerUseCase = ref.watch(registerUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _repository = ref.watch(authRepositoryProvider);

    // Run auth check asynchronously after build to avoid modifying state during build
    Future.microtask(() => checkAuthStatus());

    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    final user = await _repository.getSavedUser();
    final token = await _repository.getToken();
    if (user != null && token != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _loginUseCase(email: email, password: password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(_mapErrorToMessage(e));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _registerUseCase(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(_mapErrorToMessage(e));
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logoutUseCase();
    } catch (_) {
      // Proceed to unauthenticated state even if API call fails
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> forceLogout() async {
    try {
      await _repository.deleteToken();
      await _repository.logout();
    } catch (_) {
      // Safe to ignore on forced logout
    } finally {
      state = const AuthUnauthenticated(
        message: 'Sessão expirada. Por favor, faça login novamente.',
      );
    }
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'E-mail ou senha incorretos.';
      } else if (error.response?.statusCode == 422) {
        final data = error.response?.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            return errors.values.first.toString().replaceAll('[', '').replaceAll(']', '');
          }
          final message = data['message'];
          if (message is String) {
            return message;
          }
        }
        return 'Dados de validação incorretos.';
      }
      return 'Erro de conexão com o servidor. Verifique sua internet.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
