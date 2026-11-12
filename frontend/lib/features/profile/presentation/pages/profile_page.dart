import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/core/widgets/section_card.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/profile_avatar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, profile)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildProfileCard(context, profile),
                  const SizedBox(height: 16),
                  _buildStatsRow(context),
                  const SizedBox(height: 16),
                  _buildTargetSection(context),
                  const SizedBox(height: 16),
                  _buildPrivacySection(context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 16),
                  _buildFooter(context),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, UserProfile profile) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SleepWiseLogo(size: 38, borderRadius: 10),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SleepWise',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Profil Sleepwise',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Ganti Tema',
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                icon: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: isDarkMode ? const Color(0xFF60A5FA) : Colors.amber,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                child: ProfileAvatar(
                  avatarId: profile.avatarId,
                  radius: 18,
                  showBorder: true,
                  borderColor: colors.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile profile) {
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ProfileAvatar(
                  avatarId: profile.avatarId,
                  radius: 36,
                  showBorder: true,
                  borderColor: AppTheme.primary,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.fullName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 12, color: AppTheme.success),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.occupation} Terverifikasi',
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.email}  •  @${profile.username}',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Lahir ${profile.birthDateFormatted}  •  ',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
              Text(
                'Sirkadian Aktif',
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '88',
            '/100',
            'Optimal',
            'Skor Sirkadian',
            AppTheme.success,
            Icons.nightlight_round,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '7.4',
            ' Jam',
            'Konsisten',
            'Durasi Rata-rata',
            AppTheme.info,
            Icons.access_time,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '14',
            ' Hari',
            'Disiplin',
            'Runtun Evaluasi',
            AppTheme.accentOrange,
            Icons.local_fire_department,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String unit,
    String status,
    String label,
    Color color,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.track_changes,
            title: 'Target Sirkadian Harian',
            subtitle: 'Parameter acuan algoritma evaluasi',
            trailing: Row(
              children: [
                Text(
                  'Sesuaikan',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.tune, color: colors.onSurfaceVariant, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tambahkan parameter iconColor sesuai warna dari AppTheme
          _buildListItem(
            context,
            Icons.bedtime,
            'TARGET DURASI',
            '7.5 - 8.5 Jam',
            Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            iconColor: AppTheme.primaryLight,
          ),
          _buildListItem(
            context,
            Icons.access_alarm,
            'JAM REHAT IDEAL',
            '23:00 WIB',
            Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            iconColor: AppTheme.warning,
          ),
          _buildListItem(
            context,
            Icons.coffee,
            'BATAS KAFEIN SORE',
            'Maks. 2 Cangkir (15:00)',
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            iconColor: AppTheme.accentOrange,
          ),
          _buildListItem(
            context,
            Icons.smartphone,
            'LAYAR PRA-TIDUR',
            'Maks. 30 Menit',
            const Icon(Icons.verified, color: AppTheme.success, size: 16),
            iconColor: AppTheme.success,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.security,
            title: 'Privasi & Sinkronisasi',
            subtitle: 'Kendali data sensor dan integrasi akun',
          ),
          const SizedBox(height: 16),
          _buildListItem(
            context,
            Icons.download,
            'Ekspor Prediksi & Riwayat',
            'Unduh laporan format CSV atau PDF',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PDF/CSV',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            iconColor: AppTheme.primaryLight, // Tambahkan warna di sini
          ),
          _buildListItem(
            context,
            Icons.watch,
            'Google Fit & Smartwatch',
            'Sensor detak jantung & akselerometer',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Terhubung',
                    style: TextStyle(color: AppTheme.success, fontSize: 9),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            iconColor: AppTheme.success, // Menambahkan warna hijau
          ),
          _buildListItem(
            context,
            Icons.vpn_key,
            'Keamanan & Autentikasi',
            'Ganti kata sandi & 2FA',
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            iconColor: AppTheme.accentBlue, // Menambahkan warna biru
          ),
          _buildListItem(
            context,
            Icons.help_outline,
            'Pusat Bantuan & Metodologi ML',
            'Dokumentasi transparansi data klinis',
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            iconColor: AppTheme.warning, // Menambahkan warna oranye/kuning
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget trailing, {
    bool isLast = false,
    Color? iconColor,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.brightness == Brightness.dark
            ? AppTheme.background
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            // Terapkan warna jika diberikan, jika tidak gunakan textSecondary sebagai default
            child: Icon(
              icon,
              color: iconColor ?? colors.onSurfaceVariant,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.1),
          foregroundColor: AppTheme.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'SleepWise Mobile v1.4.2  •  ML Engine 2.1',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Dikembangkan untuk Riset Pola Sirkadian Akademik',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
        ),
      ],
    );
  }
}
