import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Alamat backend Flask. Timpa saat run:
/// `flutter run --dart-define=API_BASE=http://192.168.7.2:5000/api`
const _apiOverride = String.fromEnvironment('API_BASE');

/// Android (emulator & HP via USB) butuh `adb reverse tcp:5000 tcp:5000`
/// supaya 127.0.0.1 di perangkat menunjuk backend di laptop.
const apiBase = _apiOverride == '' ? 'http://127.0.0.1:5000/api' : _apiOverride;

class AuthUser {
  const AuthUser({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.role,
    required this.token,
  });

  final int id;
  final String namaLengkap;
  final String email;
  final String role;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] as num).toInt(),
        namaLengkap: json['nama_lengkap'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'user',
        token: json['token'] as String? ?? '',
      );
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthUser> login(String email, String kataSandi) =>
      _post('/auth/login', {'email': email, 'kata_sandi': kataSandi});

  Future<AuthUser> register(String namaLengkap, String email, String kataSandi) =>
      _post('/auth/register', {
        'nama_lengkap': namaLengkap,
        'email': email,
        'kata_sandi': kataSandi,
      });

  Future<AuthUser> _post(String path, Map<String, String> body) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$apiBase$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Tidak bisa menghubungi server ($apiBase).\n$e');
    }

    final data = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
    }
    final details = (data['details'] as List?)?.join(', ');
    throw AuthException(details ?? (data['error'] as String?) ?? 'Permintaan gagal.');
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

/// Sesi login. Null = belum login.
final authSessionProvider = NotifierProvider<AuthSession, AuthUser?>(AuthSession.new);

class AuthSession extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  void set(AuthUser? user) => state = user;
  void clear() => state = null;
}
