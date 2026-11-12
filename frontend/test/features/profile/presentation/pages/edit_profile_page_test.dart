import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/profile/presentation/providers/user_profile_provider.dart';

void main() {
  Widget buildTestableWidget({
    Widget? child,
    String initialRoute = '/edit-profile',
    ProviderContainer? container,
  }) {
    final app = Consumer(
      builder: (context, ref, _) {
        final isDark = ref.watch(themeModeProvider);
        return MaterialApp(
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => const ProfilePage(),
            '/profile': (context) => const ProfilePage(),
            AppRoutes.editProfile: (context) => const EditProfilePage(),
          },
        );
      },
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: app,
      );
    }

    return ProviderScope(child: app);
  }

  void setTestViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  testWidgets('EditProfilePage me-render semua 6 variabel profil dengan data awal', (
    tester,
  ) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // 1. Header & Title
    expect(find.text('Edit Profil'), findsOneWidget);

    // 2. Avatar / Foto Profil
    expect(find.text('Ganti Foto Profil'), findsOneWidget);

    // 3. Nama Lengkap & Username
    expect(find.text('Sarah Nabila'), findsOneWidget);
    expect(find.text('sarahnabila'), findsOneWidget);

    // 4. Tanggal Lahir
    expect(find.text('14 Mei 2002'), findsOneWidget);

    // 5. Jenis Kelamin
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('Laki-laki'), findsOneWidget);

    // 6. Pekerjaan
    expect(find.text('Mahasiswa'), findsOneWidget);

    // 7. Alamat Email
    expect(find.text('sarah.nabila@kampus.ac.id'), findsOneWidget);

    // 8. Action Buttons
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
  });

  testWidgets('validasi form memunculkan pesan error saat nama atau email invalid', (
    tester,
  ) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Kosongkan nama lengkap
    final nameField = find.widgetWithText(TextFormField, 'Sarah Nabila');
    await tester.enterText(nameField, '');

    // Masukkan email salah
    final emailField = find.widgetWithText(TextFormField, 'sarah.nabila@kampus.ac.id');
    await tester.enterText(emailField, 'email-salah');

    // Tekan tombol Simpan Perubahan
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Nama lengkap tidak boleh kosong'), findsOneWidget);
    expect(find.text('Format email tidak valid'), findsOneWidget);
  });

  testWidgets('pengguna dapat memilih jenis kelamin Laki-laki', (tester) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laki-laki'));
    await tester.pumpAndSettle();

    expect(find.text('Laki-laki'), findsOneWidget);
  });

  testWidgets('membuka dialog DatePicker saat kolom Tanggal Lahir ditekan', (
    tester,
  ) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap field tanggal lahir
    await tester.tap(find.text('14 Mei 2002'));
    await tester.pumpAndSettle();

    // Dialog DatePicker terbuka tanpa error No MaterialLocalizations
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('toggle tema pada EditProfilePage berfungsi berganti Dark dan Light mode', (
    tester,
  ) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Ganti Tema'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
  });

  testWidgets('membuka modal avatar picker dan memilih avatar baru', (tester) async {
    setTestViewport(tester);
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ganti Foto Profil'));
    await tester.pumpAndSettle();

    // Verifikasi BottomSheet terbuka
    expect(find.text('Pilih Avatar Profil'), findsOneWidget);
    expect(find.text('Sirkadian'), findsOneWidget);

    // Pilih avatar Sirkadian
    await tester.tap(find.text('Sirkadian'));
    await tester.pumpAndSettle();

    // Terapkan avatar
    await tester.tap(find.text('Terapkan Avatar'));
    await tester.pumpAndSettle();

    // Modal tertutup
    expect(find.text('Pilih Avatar Profil'), findsNothing);
  });

  testWidgets('simpan perubahan berhasil mengupdate state dan kembali ke halaman profil', (
    tester,
  ) async {
    setTestViewport(tester);
    final container = ProviderContainer();

    await tester.pumpWidget(
      buildTestableWidget(
        initialRoute: '/profile',
        container: container,
      ),
    );
    await tester.pumpAndSettle();

    // Dari ProfilePage, klik Edit Profil
    await tester.tap(find.text('Edit Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Informasi Pribadi'), findsOneWidget);

    // Ubah nama lengkap
    final nameField = find.widgetWithText(TextFormField, 'Sarah Nabila');
    await tester.enterText(nameField, 'Sarah Nabila Putri');

    // Ubah username
    final usernameField = find.widgetWithText(TextFormField, 'sarahnabila');
    await tester.enterText(usernameField, 'sarahputri');

    // Tekan Simpan Perubahan
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    // Verifikasi kembali ke ProfilePage dengan nama baru
    expect(find.text('Sarah Nabila Putri'), findsOneWidget);
    expect(find.text('sarah.nabila@kampus.ac.id  •  @sarahputri'), findsOneWidget);

    // Verifikasi provider state terupdate
    final updatedProfile = container.read(userProfileProvider);
    expect(updatedProfile.fullName, 'Sarah Nabila Putri');
    expect(updatedProfile.username, 'sarahputri');
  });
}
