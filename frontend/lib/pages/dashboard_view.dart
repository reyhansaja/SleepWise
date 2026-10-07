import 'package:flutter/material.dart';

// Warna utama dipusatkan di sini agar tampilan dashboard mudah disesuaikan.
const _background = Color(0xFF0A1022);
const _surface = Color(0xFF192238);
const _surfaceDark = Color(0xFF10192D);
const _textPrimary = Color(0xFFE0E6FF);
const _textSecondary = Color(0xFFB5BDD2);
const _mint = Color(0xFF43DFAE);
const _orange = Color(0xFFFFB34D);

// Halaman utama menyimpan tab yang dipilih dan menyusun konten yang bisa digulir.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth > 520
                      ? 520.0
                      : constraints.maxWidth;
                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        child: const _DashboardContent(),
                      ),
                    ),
                  );
                },
              ),
            ),
            _BottomNavigation(
              selectedIndex: _selectedTab,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
          ],
        ),
      ),
    );
  }
}

// Bagian ini berisi urutan kartu utama seperti pada rancangan dashboard.
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DashboardHeader(),
        const SizedBox(height: 18),
        Text(
          _formattedToday(),
          style: const TextStyle(
            color: Color(0xFFB4BCEB),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Selamat Pagi, Sarah! ✨',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 29,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kualitas istirahatmu tadi malam tergolong prima.',
          style: TextStyle(color: _textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 22),
        const _SleepSummaryCard(),
        const SizedBox(height: 28),
        const _PredictionBanner(),
        const SizedBox(height: 26),
        const _StatisticsSection(),
        const SizedBox(height: 25),
        const _RoutineCard(),
        const SizedBox(height: 20),
        const _DailyTipCard(),
      ],
    );
  }
}

// Header menampilkan identitas aplikasi dan avatar pengguna.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF252C53),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.nights_stay_rounded, color: _mint, size: 21),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SleepWise',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Dashboard',
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF333D58), width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFFF5D4B3), Color(0xFF8CA2BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.person_rounded, color: _background, size: 25),
        ),
      ],
    );
  }
}

// Kartu ringkasan tidur merangkum skor, durasi, detak jantung, stres, dan layar.
class _SleepSummaryCard extends StatelessWidget {
  const _SleepSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D293E), Color(0xFF202844), Color(0xFF141D30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF17433F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: _mint, size: 15),
                SizedBox(width: 6),
                Text(
                  'Good Sleep (Kualitas Baik)',
                  style: TextStyle(
                    color: _mint,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Durasi Evaluasi Tidur',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 5),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '7.5',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'Jam',
                  style: TextStyle(
                    color: Color(0xFFBBC5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              _CompactTag(icon: Icons.nightlight_outlined, label: 'Tadi malam'),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _SleepMetric(
                  icon: Icons.favorite_border_rounded,
                  iconColor: Color(0xFFFF9C9C),
                  value: '64',
                  label: 'bpm detak',
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _SleepMetric(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  iconColor: _orange,
                  value: '3/10',
                  label: 'tingkat stres',
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _SleepMetric(
                  icon: Icons.devices_rounded,
                  iconColor: Color(0xFFB5C3FF),
                  value: '30m',
                  label: 'screen time',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Chip kecil digunakan untuk label waktu dan periode tidur.
class _CompactTag extends StatelessWidget {
  const _CompactTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF273149),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _mint, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: _textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Satu metrik kecil pada kartu evaluasi tidur.
class _SleepMetric extends StatelessWidget {
  const _SleepMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
      color: _surfaceDark,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// Banner ungu menonjolkan aksi untuk melihat prediksi tidur harian.
class _PredictionBanner extends StatelessWidget {
  const _PredictionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF8588FF), Color(0xFF494DB9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x403D43B5),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0x33777BF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: _background, size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prediksi Hari Ini',
                  style: TextStyle(
                    color: Color(0xFF171E67),
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Isi 7 parameter untuk estimasi instan ML',
                  style: TextStyle(
                    color: Color(0xFF292F7F),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0x33777BF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF252B80),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// Bagian statistik disusun dua kolom supaya tetap nyaman dibaca di ponsel.
class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Ringkasan Statistik',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCBD1FF),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat detail ›',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _StatCard(
                    title: 'Rata-rata Durasi',
                    icon: Icons.schedule_rounded,
                    iconColor: Color(0xFFB8C3FF),
                    value: '7.2',
                    unit: 'Jam',
                    footer: '↗ +0.4j minggu ini',
                    footerColor: _mint,
                  ),
                  SizedBox(height: 12),
                  _StatCard(
                    title: 'Rerata Stres',
                    icon: Icons.monitor_heart_rounded,
                    iconColor: _orange,
                    value: '3.4',
                    unit: '/10',
                    footer: 'Kategori Rendah',
                    footerColor: _mint,
                    footerIsTag: true,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  _StatCard(
                    title: 'Total Prediksi',
                    icon: Icons.psychology_alt_rounded,
                    iconColor: _mint,
                    value: '28',
                    unit: 'Sesi',
                    footer: '✓ Akurasi tinggi',
                    footerColor: _textSecondary,
                  ),
                  SizedBox(height: 12),
                  _DistributionCard(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Kartu statistik serbaguna untuk angka, keterangan, dan ikon ringkas.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.footer,
    required this.footerColor,
    this.footerIsTag = false,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String footer;
  final Color footerColor;
  final bool footerIsTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.fromLTRB(15, 14, 12, 13),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSecondary, fontSize: 11),
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          if (footerIsTag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF164139),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                footer,
                style: TextStyle(
                  color: footerColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              footer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: footerColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// Kartu ini menampilkan komposisi kualitas tidur dengan indikator berwarna.
class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.fromLTRB(15, 14, 12, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Distribusi',
                  style: TextStyle(color: _textSecondary, fontSize: 11),
                ),
              ),
              Icon(Icons.donut_large_rounded, color: _textPrimary, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const Row(
              children: [
                Expanded(
                  flex: 75,
                  child: SizedBox(height: 8, child: ColoredBox(color: _mint)),
                ),
                Expanded(
                  flex: 20,
                  child: SizedBox(height: 8, child: ColoredBox(color: _orange)),
                ),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 8,
                    child: ColoredBox(color: Color(0xFFFF8F8F)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: _textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: '75% Baik',
                  style: TextStyle(color: _mint),
                ),
                TextSpan(text: ' • '),
                TextSpan(
                  text: '20% Cukup',
                  style: TextStyle(color: _orange),
                ),
                TextSpan(text: ' • 5% Kurang'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu rutinitas memakai ilustrasi sederhana berbasis gradien dan ikon.
class _RoutineCard extends StatelessWidget {
  const _RoutineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF56647D),
                  Color(0xFF172137),
                  Color(0xFF362E43),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.bedtime_rounded,
              color: Color(0xFFE4D5BF),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MOMEN RELAKSASI',
                  style: TextStyle(
                    color: _orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rutinitas Jelang Tidur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Nyalakan pencahayaan hangat 45 menit sebelum terlelap untuk...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kartu tips memberi saran kebiasaan tidur harian.
class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1D273D),
        borderRadius: BorderRadius.circular(38),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF3D3C43),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: _orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tips Hari Ini',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '• Rekomendasi ML',
                      style: TextStyle(color: _textSecondary, fontSize: 9),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Hindari kafein setelah pukul 15.00 WIB untuk menjaga fase Deep Sleep optimal malam nanti.',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Navigasi bawah menjaga tab tetap terlihat seperti pada aplikasi ponsel.
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
    (label: 'Prediksi', icon: Icons.auto_awesome),
    (label: 'Riwayat', icon: Icons.history_rounded),
    (label: 'Statistik', icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1427),
        border: Border(top: BorderSide(color: Color(0xFF202A40), width: 0.7)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF29314F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? const Color(0xFFD2D6FF)
                                  : _textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFD2D6FF)
                                  : _textSecondary,
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// Tanggal diperbarui mengikuti perangkat dengan nama hari dan bulan Indonesia.
String _formattedToday() {
  const days = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];
  const months = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];
  final today = DateTime.now();
  return '${days[today.weekday - 1]}, ${today.day} '
      '${months[today.month - 1]} ${today.year}';
}
