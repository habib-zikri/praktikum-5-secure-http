import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);
  // GET /users
  Future<List<User>> getUsers() async {
    try {
      print('Request GET: $_baseUrl/users');
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(_timeout);
      // Logging aman: hanya status code
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw HttpException(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      throw Exception('Format data tidak valid.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /users/{id}
  Future<User> getUserById(int id) async {
    try {
      print('Request GET: $_baseUrl/users/$id');
      final response = await http
          .get(Uri.parse('$_baseUrl/users/$id'))
          .timeout(_timeout);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw HttpException(
          'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
  // Simulasi login untuk mendapatkan token

  Future<String> login(String email, String password) async {
    try {
      // Simulasi request login
      await Future.delayed(const Duration(seconds: 1));
      if (email.isNotEmpty && password.isNotEmpty) {
        // Token dummy (dalam aplikasi nyata, ini dari server)
        final token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
        // ✅ Logging aman: tidak mencetak token
        print('Login berhasil untuk email: $email');
        return token;
      } else {
        throw Exception('Email dan password tidak boleh kosong');
      }
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
