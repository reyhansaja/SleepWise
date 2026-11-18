import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/navigation/main_shell.dart';
import 'package:frontend/features/home/presentation/pages/dashboard_view.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:frontend/features/statistics/presentation/pages/statistics_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('menekan icon avatar di header dashboard mengarahkan ke tab profil pada navbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainShell(initialIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan berada di Dashboard
    expect(find.textContaining('Sarah! ✨'), findsOneWidget);

    // Temukan ProfileAvatar di header Dashboard dan tap
    final avatarInDashboard = find.descendant(
      of: find.byType(DashboardView),
      matching: find.byType(ProfileAvatar),
    );
    expect(avatarInDashboard, findsOneWidget);

    await tester.tap(avatarInDashboard);
    await tester.pumpAndSettle();

    // Verifikasi bahwa halaman Profil sekarang aktif
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Target Sirkadian Harian'), findsOneWidget);
  });

  testWidgets('halaman statistik tidak lagi memiliki icon profil di header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Hanya tombol ganti tema yang ada di trailing header
    expect(find.byTooltip('Ganti Tema'), findsOneWidget);
    // Tidak ada icon person_rounded
    expect(find.byIcon(Icons.person_rounded), findsNothing);
  });

  testWidgets('halaman profil tidak memiliki icon avatar kecil di header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Hanya tombol ganti tema di header kanan atas
    expect(find.byTooltip('Ganti Tema'), findsOneWidget);

    // ProfileAvatar hanya ada 1 (di kartu profil utama), tidak ada avatar kedua di header
    expect(find.byType(ProfileAvatar), findsOneWidget);
  });
}
