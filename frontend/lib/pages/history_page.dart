import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Semua';

  final List<_SleepRecord> _records = const [
    _SleepRecord('24 Mei 2024 • 07:15 WIB', 'Good Sleep', Color(0xFF34D399), '7.5 h', '3/10', '1', '64', 'Siklus REM Optimal (1.8 jam)'),
    _SleepRecord('23 Mei 2024 • 06:45 WIB', 'Good Sleep', Color(0xFF34D399), '7.0 h', '4/10', '2', '68', 'Target tidur harian tercapai'),
    _SleepRecord('22 Mei 2024 • 08:00 WIB', 'Average Sleep', Color(0xFFFBBF24), '6.2 h', '6/10', '2', '60', 'Jam tidur meningkat 25m'),
    _SleepRecord('20 Mei 2024 • 07:30 WIB', 'Poor Sleep', Color(0xFFF87171), '4.8 h', '8/10', '3', '90', 'Defisit tidur signifikan (2.7 jam)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSummary(),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  _buildFilters(),
                  const SizedBox(height: 14),
                  ..._records.map(_buildRecordCard),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Riwayat Prediksi SleepWise', style: TextStyle(color: Color(0xFF7F8AA4), fontSize: 13)),
              SizedBox(height: 5),
              Text('Riwayat Prediksi', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Arsip evaluasi & analisis cerdas tidurmu', style: TextStyle(color: Color(0xFF9BA5BB), fontSize: 11)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ios_share_rounded, size: 13),
          label: const Text('Ekspor'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB9C3FF),
            side: const BorderSide(color: Color(0xFF3A4262)),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF141B2E), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF252E47))),
      child: Row(
        children: [
          Container(width: 43, height: 43, decoration: const BoxDecoration(color: Color(0xFF252C48), shape: BoxShape.circle), child: const Icon(Icons.bedtime_rounded, color: Color(0xFFB5BFFF), size: 22)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('34', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                Text('Riwayat', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Model terverifikasi •\nTerenkripsi diperangkat', style: TextStyle(color: Color(0xFF8994AD), fontSize: 9, height: 1.3)),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF123A37), borderRadius: BorderRadius.circular(7)), child: const Text('Lokal\nSinkron', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF45D5B0), fontSize: 8, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('AKURASI\nRERATA', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF8994AD), fontSize: 7, height: 1.2)),
              SizedBox(height: 2),
              Text('92.4%', style: TextStyle(color: Color(0xFFBEC6FF), fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 11),
      decoration: InputDecoration(
        hintText: 'Cari tanggal, faktor stres, atau model...',
        hintStyle: const TextStyle(color: Color(0xFF707B94), fontSize: 10),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8F9AB2), size: 15),
        filled: true,
        fillColor: const Color(0xFF141B2E),
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Semua', 'Random Forest', 'Decision Tree', 'Good Sleep'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF9CA7BC), fontSize: 9, fontWeight: FontWeight.w600),
              backgroundColor: const Color(0xFF1D253B),
              selectedColor: const Color(0xFF4C557D),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(_SleepRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(color: const Color(0xFF141B2E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF75E6BE), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Text(record.date, style: const TextStyle(color: Color(0xFFCBD3E3), fontSize: 9, fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(color: record.qualityColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [Icon(Icons.nightlight_round, size: 9, color: record.qualityColor), const SizedBox(width: 3), Text(record.quality, style: TextStyle(color: record.qualityColor, fontSize: 8, fontWeight: FontWeight.w700))]),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_metric(Icons.access_time_rounded, record.duration, 'Durasi'), _metric(Icons.star_border_rounded, record.score, 'Skor'), _metric(Icons.bedtime_outlined, '${record.awakenings} kcr', 'Terbangun'), _metric(Icons.favorite_border_rounded, record.heartRate, 'bpm')]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Row(children: [Icon(Icons.check_circle_outline, color: record.qualityColor, size: 11), const SizedBox(width: 5), Flexible(child: Text(record.note, style: TextStyle(color: record.qualityColor, fontSize: 8, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))])),
              TextButton(onPressed: () {}, style: TextButton.styleFrom(foregroundColor: const Color(0xFFB5BEF7), padding: const EdgeInsets.symmetric(horizontal: 7), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: const Text('Lihat Detail ›', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Column(children: [Icon(icon, color: const Color(0xFFB8C0E8), size: 15), const SizedBox(height: 3), Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: Color(0xFF8893AB), fontSize: 8))]);
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF11182A),
      selectedItemColor: const Color(0xFFB5BEF7),
      unselectedItemColor: const Color(0xFF68738B),
      selectedFontSize: 9,
      unselectedFontSize: 9,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'Prediksi'),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Statistik'),
      ],
    );
  }
}

class _SleepRecord {
  final String date;
  final String quality;
  final Color qualityColor;
  final String duration;
  final String score;
  final String awakenings;
  final String heartRate;
  final String note;

  const _SleepRecord(this.date, this.quality, this.qualityColor, this.duration, this.score, this.awakenings, this.heartRate, this.note);
}