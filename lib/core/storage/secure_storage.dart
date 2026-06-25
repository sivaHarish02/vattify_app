import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Singleton pattern
  SecureStorage._privateConstructor();
  static final SecureStorage instance = SecureStorage._privateConstructor();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  // Save Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Delete Token
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Save User Info
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user));
  }

  // Get User Info
  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: _keyUser);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Delete User Info
  Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }

  // Clear Session
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
