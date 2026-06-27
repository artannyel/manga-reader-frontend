import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

final Provider<AuthRepository> authRepositoryImplProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(remoteDataSource, secureStorage);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _secureStorage.saveToken(response.token);
    await _secureStorage.saveUser(response.user);
    return response.user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
    await _secureStorage.saveToken(response.token);
    await _secureStorage.saveUser(response.user);
    return response.user;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _secureStorage.deleteToken();
      await _secureStorage.deleteUser();
    }
  }

  @override
  Future<String?> getToken() {
    return _secureStorage.getToken();
  }

  @override
  Future<void> deleteToken() {
    return _secureStorage.deleteToken();
  }

  @override
  Future<User?> getSavedUser() {
    return _secureStorage.getUser();
  }
}
