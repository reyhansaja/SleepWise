// Uji alur UI Login/Register: halaman benar-benar memanggil AuthApi.
// Klien HTTP dipalsukan di sini; jaringan nyata diuji di auth_api_test.dart.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(AuthApi api) => ProviderScope(
      overrides: [authApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/main': (_) => const Scaffold(body: Text('BERANDA')),
        },
      ),
    );

String _userJson(Map<String, dynamic> body) => jsonEncode({
      'status': 'success',
      'data': {
        'id': 7,
        'nama_lengkap': body['nama_lengkap'] ?? 'Budi',
        'email': body['email'],
        'role': 'user',
        'token': 'token-palsu',
      },
    });

/// AuthApi dengan klien palsu: selalu balas [status]; rekam body yang dikirim.
({AuthApi api, Map<String, dynamic>? Function() sent}) _fake(int status) {
  Map<String, dynamic>? sent;
  final api = AuthApi(
    client: MockClient((req) async {
      sent = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(
        status < 300
            ? _userJson(sent!)
            : jsonEncode({'status': 'error', 'error': 'email atau kata sandi salah'}),
        status,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
  return (api: api, sent: () => sent);
}

void _enlargeView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('login salah menampilkan pesan error dari backend', (tester) async {
    _enlargeView(tester);
    final fake = _fake(401);

    await tester.pumpWidget(_app(fake.api));
    await tester.enterText(find.byType(TextField).at(0), 'budi@sleepwise.test');
    await tester.enterText(find.byType(TextField).at(1), 'salahsekali');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.text('email atau kata sandi salah'), findsOneWidget);
    expect(find.text('BERANDA'), findsNothing);
  });

  testWidgets('login benar membuka beranda', (tester) async {
    _enlargeView(tester);
    final fake = _fake(200);

    await tester.pumpWidget(_app(fake.api));
    await tester.enterText(find.byType(TextField).at(0), 'budi@sleepwise.test');
    await tester.enterText(find.byType(TextField).at(1), 'rahasia123');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(fake.sent(), {'email': 'budi@sleepwise.test', 'kata_sandi': 'rahasia123'});
    expect(find.text('BERANDA'), findsOneWidget);
  });

  testWidgets('register mengirim nama lengkap, email, kata sandi', (tester) async {
    _enlargeView(tester);
    final fake = _fake(201);

    await tester.pumpWidget(_app(fake.api));
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Nama Uji UI');
    await tester.enterText(find.byType(TextField).at(1), 'baru@sleepwise.test');
    await tester.enterText(find.byType(TextField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextField).at(3), 'rahasia123');
    await tester.tap(find.text('Daftar Akun SleepWise'));
    await tester.pumpAndSettle();

    expect(fake.sent(), {
      'nama_lengkap': 'Nama Uji UI',
      'email': 'baru@sleepwise.test',
      'kata_sandi': 'rahasia123',
    });
    expect(find.text('BERANDA'), findsOneWidget);
  });
}
