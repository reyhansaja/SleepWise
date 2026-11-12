// Uji AuthApi terhadap backend Flask sungguhan (bukan mock).
// Butuh backend jalan: `python backend/app.py`. Bila server mati, test di-skip.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

Future<bool> _serverUp() async {
  final uri = Uri.parse(apiBase).replace(path: '/api/health');
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    final res = await (await client.getUrl(uri)).close();
    await res.drain<void>();
    client.close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void main() {
  late bool up;

  setUpAll(() async => up = await _serverUp());

  test('register lalu login lewat backend', () async {
    if (!up) {
      markTestSkipped('backend tidak aktif di $apiBase');
      return;
    }
    final api = AuthApi();
    final email = 'fe-${DateTime.now().millisecondsSinceEpoch}@sleepwise.test';

    final user = await api.register('Budi Frontend', email, 'rahasia123');
    expect(user.role, 'user');
    expect(user.namaLengkap, 'Budi Frontend');
    expect(user.token, isNotEmpty);

    final logged = await api.login(email, 'rahasia123');
    expect(logged.email, email);
    expect(logged.id, user.id);

    await expectLater(api.login(email, 'salahsekali'), throwsA(isA<AuthException>()));
    await expectLater(api.register('Budi', email, 'rahasia123'), throwsA(isA<AuthException>()));
  }, timeout: const Timeout(Duration(seconds: 40)));
}
