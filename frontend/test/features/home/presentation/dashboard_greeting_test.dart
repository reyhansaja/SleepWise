import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/home/presentation/pages/dashboard_view.dart';
import 'package:frontend/features/profile/presentation/providers/user_profile_provider.dart';

void main() {
  group('getGreeting logic', () {
    test('mengembalikan Selamat Pagi untuk jam 04:00 - 10:59', () {
      expect(getGreeting(DateTime(2026, 1, 1, 4, 0)), 'Selamat Pagi');
      expect(getGreeting(DateTime(2026, 1, 1, 8, 30)), 'Selamat Pagi');
      expect(getGreeting(DateTime(2026, 1, 1, 10, 59)), 'Selamat Pagi');
    });

    test('mengembalikan Selamat Siang untuk jam 11:00 - 14:59', () {
      expect(getGreeting(DateTime(2026, 1, 1, 11, 0)), 'Selamat Siang');
      expect(getGreeting(DateTime(2026, 1, 1, 13, 0)), 'Selamat Siang');
      expect(getGreeting(DateTime(2026, 1, 1, 14, 59)), 'Selamat Siang');
    });

    test('mengembalikan Selamat Sore untuk jam 15:00 - 17:59', () {
      expect(getGreeting(DateTime(2026, 1, 1, 15, 0)), 'Selamat Sore');
      expect(getGreeting(DateTime(2026, 1, 1, 16, 45)), 'Selamat Sore');
      expect(getGreeting(DateTime(2026, 1, 1, 17, 59)), 'Selamat Sore');
    });

    test('mengembalikan Selamat Malam untuk jam 18:00 - 03:59', () {
      expect(getGreeting(DateTime(2026, 1, 1, 18, 0)), 'Selamat Malam');
      expect(getGreeting(DateTime(2026, 1, 1, 21, 30)), 'Selamat Malam');
      expect(getGreeting(DateTime(2026, 1, 1, 23, 59)), 'Selamat Malam');
      expect(getGreeting(DateTime(2026, 1, 1, 0, 0)), 'Selamat Malam');
      expect(getGreeting(DateTime(2026, 1, 1, 3, 59)), 'Selamat Malam');
    });
  });

  group('getFirstName logic', () {
    test('mengambil satu kata pertama dari berbagai format nama', () {
      expect(getFirstName('Sarah Nabila'), 'Sarah');
      expect(getFirstName('Muhammad Rizky Pratama'), 'Muhammad');
      expect(getFirstName('  Dimas  '), 'Dimas');
      expect(getFirstName('Adit'), 'Adit');
      expect(getFirstName(''), 'Pengguna');
      expect(getFirstName('   '), 'Pengguna');
    });
  });

  testWidgets('Dashboard menampilkan sapaan dinamis dan berubah saat nama profil diubah', (
    tester,
  ) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: DashboardView(showBottomNav: false)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final expectedGreeting = getGreeting();

    // Pastikan sapaan awal menggunakan nama Sarah
    expect(find.text('$expectedGreeting, Sarah! ✨'), findsOneWidget);

    // Ubah nama profil di provider menjadi Dimas Anggara
    final currentProfile = container.read(userProfileProvider);
    container.read(userProfileProvider.notifier).updateProfile(
          currentProfile.copyWith(fullName: 'Dimas Anggara'),
        );
    await tester.pumpAndSettle();

    // Sapaan otomatis berubah menjadi hanya nama depan (Dimas)
    expect(find.text('$expectedGreeting, Dimas! ✨'), findsOneWidget);
  });
}
