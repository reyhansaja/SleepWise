// Uji halaman prediksi: payload yang dikirim + kartu hasil yang dirender.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/prediction/data/repositories/api_prediction_repository.dart';
import 'package:frontend/features/prediction/presentation/pages/prediction_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(AuthApiLike like) => ProviderScope(
      overrides: [predictionRepositoryProvider.overrideWithValue(like.api)],
      child: const MaterialApp(home: PredictionPage()),
    );

/// Bungkus klien palsu + rekam payload terakhir.
class AuthApiLike {
  AuthApiLike(this.api, this.sent);
  final ApiPredictionRepository api;
  final Map<String, dynamic>? Function() sent;
}

AuthApiLike _fake(int status, Map<String, dynamic> body) {
  Map<String, dynamic>? sent;
  final api = ApiPredictionRepository(
    client: MockClient((req) async {
      sent = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(jsonEncode(body), status,
          headers: {'content-type': 'application/json'});
    }),
  );
  return AuthApiLike(api, () => sent);
}

void _enlargeView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('hasil prediksi backend tampil di kartu', (tester) async {
    _enlargeView(tester);
    final fake = _fake(201, {
      'status': 'success',
      'prediction': 'Poor',
      'confidence': 0.87,
      'recommendations': [
        {'category': 'stres', 'message': 'Turunkan tingkat stres sebelum tidur.'},
        {'category': 'tidur', 'message': 'Tidur minimal 7 jam per malam.'},
      ],
    });

    await tester.pumpWidget(_app(fake));
    await tester.tap(find.text('Prediksi Kualitas Tidur Sekarang'));
    // halaman memakai animasi glow berulang -> pumpAndSettle tak akan selesai
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Perlu perhatian'), findsOneWidget);
    expect(find.text('keyakinan 87%'), findsOneWidget);
    expect(find.text('Turunkan tingkat stres sebelum tidur.'), findsOneWidget);
    expect(find.text('Tidur minimal 7 jam per malam.'), findsOneWidget);

    // payload yang dikirim sesuai kontrak backend
    final sent = fake.sent()!;
    expect(sent['sleep_duration'], 7.5);
    expect(sent['stress_level'], 4);
    expect(sent['heart_rate'], 68);
    expect(sent['bmi_category'], 'Normal');
    expect(sent['physical_activity_level'], 45);
    expect(sent.keys, containsAll(<String>[
      'gender', 'age', 'daily_steps', 'systolic_bp', 'diastolic_bp', 'sleep_disorder',
    ]));
  });

  testWidgets('error backend tampil, tidak ada kartu hasil', (tester) async {
    _enlargeView(tester);
    final fake = _fake(400, {
      'status': 'error',
      'error': 'validasi gagal',
      'details': ["Field 'heart_rate' harus di antara 30 dan 220."],
    });

    await tester.pumpWidget(_app(fake));
    await tester.tap(find.text('Prediksi Kualitas Tidur Sekarang'));
    // halaman memakai animasi glow berulang -> pumpAndSettle tak akan selesai
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text("Field 'heart_rate' harus di antara 30 dan 220."), findsOneWidget);
    expect(find.text('Perlu perhatian'), findsNothing);
  });
}
