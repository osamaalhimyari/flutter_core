import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Auth-token persistence contract. The network layer depends on this, not on
/// any concrete storage, so the token source is swappable.
abstract class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// [TokenStorage] backed by the platform secure store (Keychain / Keystore).
/// The default used by `Core.init` when you don't pass your own.
class SecureTokenStorage implements TokenStorage {
  static const _key = 'auth_token';
  final FlutterSecureStorage _fs;
  SecureTokenStorage([FlutterSecureStorage? fs])
    : _fs = fs ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _fs.read(key: _key);
  @override
  Future<void> write(String token) => _fs.write(key: _key, value: token);
  @override
  Future<void> clear() => _fs.delete(key: _key);
}

/// Non-persistent [TokenStorage] kept in memory. Handy in tests.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;
  @override
  Future<void> write(String token) async => _token = token;
  @override
  Future<void> clear() async => _token = null;
}
