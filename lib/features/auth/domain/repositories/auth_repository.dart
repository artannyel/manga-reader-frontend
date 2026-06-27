import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String?> getToken();

  Future<void> deleteToken();

  Future<User?> getSavedUser();
}
