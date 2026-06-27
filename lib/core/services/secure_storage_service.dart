import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/entities/user.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SecureStorageService(secureStorage);
});

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  SecureStorageService(this._secureStorage);

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveUser(User user) async {
    final jsonStr = json.encode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
    });
    await _secureStorage.write(key: _userKey, value: jsonStr);
  }

  Future<User?> getUser() async {
    final jsonStr = await _secureStorage.read(key: _userKey);
    if (jsonStr == null) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return User(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: _userKey);
  }
}
