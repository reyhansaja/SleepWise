import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/section_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildTargetSection(),
                  const SizedBox(height: 16),
                  _buildPrivacySection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 16),
                  _buildFooter(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SleepWise',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Profil Sleepwise',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
              color: AppTheme.surfaceLight,
            ),
            child: ClipOval(
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return SectionCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.surfaceLight,
                  child: Icon(Icons.person, size: 40, color: AppTheme.textSecondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sarah Nabila',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 12, color: AppTheme.success),
                    SizedBox(width: 4),
                    Text(
                      'Mahasiswa Terverifikasi',
                      style: TextStyle(
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
          const Text(
            'sarah.nabila@kampus.ac.id',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              const Text('Anggota sejak Maret 2024  •  ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              const Text('Sirkadian Aktif', style: TextStyle(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text('Edit Profil', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('88', '/100', 'Optimal', 'Skor Sirkadian', AppTheme.success, Icons.nightlight_round)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('7.4', ' Jam', 'Konsisten', 'Durasi Rata-rata', AppTheme.info, Icons.access_time)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('14', ' Hari', 'Disiplin', 'Runtun Evaluasi', AppTheme.accentOrange, Icons.local_fire_department)),
      ],
    );
  }

  Widget _buildStatCard(String value, String unit, String status, String label, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
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
                    Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, height: 1)),
                    Text(unit, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, height: 1.5)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSection() {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionHeader(
            icon: Icons.track_changes,
            title: 'Target Sirkadian Harian',
            subtitle: 'Parameter acuan algoritma evaluasi',
            trailing: Row(
              children: [
                Text('Sesuaikan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                SizedBox(width: 4),
                Icon(Icons.tune, color: AppTheme.textSecondary, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tambahkan parameter iconColor sesuai warna dari AppTheme
          _buildListItem(Icons.bedtime, 'TARGET DURASI', '7.5 - 8.5 Jam', const Icon(Icons.edit, color: AppTheme.textMuted, size: 16), iconColor: AppTheme.primaryLight),
          _buildListItem(Icons.access_alarm, 'JAM REHAT IDEAL', '23:00 WIB', const Icon(Icons.edit, color: AppTheme.textMuted, size: 16), iconColor: AppTheme.warning),
          _buildListItem(Icons.coffee, 'BATAS KAFEIN SORE', 'Maks. 2 Cangkir (15:00)', const Icon(Icons.check_circle_outline, color: AppTheme.textMuted, size: 16), iconColor: AppTheme.accentOrange),
          _buildListItem(Icons.smartphone, 'LAYAR PRA-TIDUR', 'Maks. 30 Menit', const Icon(Icons.verified, color: AppTheme.success, size: 16), iconColor: AppTheme.success, isLast: true),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SectionHeader(
            icon: Icons.security,
            title: 'Privasi & Sinkronisasi',
            subtitle: 'Kendali data sensor dan integrasi akun',
          ),
          const SizedBox(height: 16),
            _buildListItem(
            Icons.download,
            'Ekspor Prediksi & Riwayat',
            'Unduh laporan format CSV atau PDF',
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PDF/CSV', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 16),
              ],
            ),
            iconColor: AppTheme.primaryLight, // Tambahkan warna di sini
          ),          _buildListItem(
            Icons.watch,
            'Google Fit & Smartwatch',
            'Sensor detak jantung & akselerometer',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Terhubung', style: TextStyle(color: AppTheme.success, fontSize: 9)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 16),
              ],
            ),
            iconColor: AppTheme.success, // Menambahkan warna hijau
          ),
          _buildListItem(
            Icons.vpn_key, 
            'Keamanan & Autentikasi', 
            'Ganti kata sandi & 2FA', 
            const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 16),
            iconColor: AppTheme.accentBlue, // Menambahkan warna biru
          ),
          _buildListItem(
            Icons.help_outline, 
            'Pusat Bantuan & Metodologi ML', 
            'Dokumentasi transparansi data klinis', 
            const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 16), 
            iconColor: AppTheme.warning, // Menambahkan warna oranye/kuning
            isLast: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildListItem(IconData icon, String title, String subtitle, Widget trailing, {bool isLast = false, Color? iconColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            // Terapkan warna jika diberikan, jika tidak gunakan textSecondary sebagai default
            child: Icon(icon, color: iconColor ?? AppTheme.textSecondary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
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
        label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text('SleepWise Mobile v1.4.2  •  ML Engine 2.1', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('Dikembangkan untuk Riset Pola Sirkadian Akademik', style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
      ],
    );
  }
}