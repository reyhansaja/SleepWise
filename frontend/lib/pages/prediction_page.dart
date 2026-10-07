import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/prediction/durasi_tidur_widget.dart';
import '../widgets/prediction/aktivitas_fisik_widget.dart';
import '../widgets/prediction/tingkat_stres_widget.dart';
import '../widgets/prediction/kafein_widget.dart';
import '../widgets/prediction/layar_malam_widget.dart';
import '../widgets/prediction/detak_jantung_widget.dart';
import '../widgets/prediction/bmi_widget.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with SingleTickerProviderStateMixin {
  // ── State variables ──
  double _durasiTidur = 7.5;
  int _aktivitasFisikIndex = 1; // Sedang
  double _tingkatStres = 4;
  int _kafein = 1;
  double _layarMalam = 45;
  int _detakJantung = 68;
  int _bmiIndex = 1; // Normal

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverToBoxAdapter(child: _buildHeader()),
            // ── Content ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildModelChips(),
                  const SizedBox(height: 20),
                  DurasiTidurWidget(
                    value: _durasiTidur,
                    onChanged: (v) => setState(() => _durasiTidur = v),
                  ),
                  const SizedBox(height: 12),
                  AktivitasFisikWidget(
                    selectedIndex: _aktivitasFisikIndex,
                    onChanged: (v) =>
                        setState(() => _aktivitasFisikIndex = v),
                  ),
                  const SizedBox(height: 12),
                  TingkatStresWidget(
                    value: _tingkatStres,
                    onChanged: (v) => setState(() => _tingkatStres = v),
                  ),
                  const SizedBox(height: 12),
                  KafeinWidget(
                    value: _kafein,
                    onDecrement: () {
                      if (_kafein > 0) setState(() => _kafein--);
                    },
                    onIncrement: () => setState(() => _kafein++),
                  ),
                  const SizedBox(height: 12),
                  LayarMalamWidget(
                    value: _layarMalam,
                    onChanged: (v) => setState(() => _layarMalam = v),
                  ),
                  const SizedBox(height: 12),
                  DetakJantungWidget(
                    value: _detakJantung,
                    onChanged: (v) => setState(() => _detakJantung = v),
                  ),
                  const SizedBox(height: 12),
                  BmiWidget(
                    selectedIndex: _bmiIndex,
                    onChanged: (v) => setState(() => _bmiIndex = v),
                  ),
                  const SizedBox(height: 20),
                  _buildBioFeedbackPreview(),
                  const SizedBox(height: 20),
                  _buildCtaButton(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Center(
              child: Text(
                'SW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                'Prediksi Kualitas',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Banner ──
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppTheme.accentOrange,
            size: 16,
          ),
          const SizedBox(width: 6),
          const Text(
            'Didukung Random Forest & Decision Tree',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Title Section ──
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Prediksi Kualitas Tidur',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan metrik harian untuk kalkukasi biomarker istirahat & pemulihan saraf Anda malam ini.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Model Chips ──
  Widget _buildModelChips() {
    return Row(
      children: [
        Expanded(child: _buildChip(
          icon: Icons.account_tree_rounded,
          label: 'Random Forest',
          sublabel: 'Ensemble > 92% Akurasi',
          color: AppTheme.accent,
        )),
        const SizedBox(width: 10),
        Expanded(child: _buildChip(
          icon: Icons.schema_rounded,
          label: 'Decision Tree',
          sublabel: 'Visual Jalur Transparansi',
          color: AppTheme.accentBlue,
        )),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bio-Feedback Preview ──
  Widget _buildBioFeedbackPreview() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Text(
              'BIO-FEEDBACK PREVIEW',
              style: TextStyle(
                color: AppTheme.primaryLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Data Siap Dikomputasi',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Model akan memetakan risiko sleep fragmentation.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA Button ──
  Widget _buildCtaButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.3 + (_glowController.value * 0.4);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: glowOpacity),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Implement prediction logic
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.ctaGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Prediksi Kualitas Tidur Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚡ Estimasi kalkulasi model < 1 detik • Privasi data lokal terjamin',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
