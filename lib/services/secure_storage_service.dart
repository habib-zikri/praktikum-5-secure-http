import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  // Key yang digunakan
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';
  // Menyimpan token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // ✅ Logging aman: tidak mencetak token
    print('Token berhasil disimpan');
  }

  // Membaca token
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    // ✅ Logging aman: hanya menyebutkan status
    print(token != null ? 'Token ditemukan' : 'Token tidak ditemukan');
    return token;
  }

  // Menghapus token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token berhasil dihapus');
  }

  // Menyimpan PIN
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    print('PIN berhasil disimpan');
  }

  // Membaca PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Menghapus semua data
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    print('Semua data berhasil dihapus');
  }

  // Cek keberadaan token
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }
}
