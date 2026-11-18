import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/prediction/data/repositories/remote_prediction_repository.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_input.dart';
import 'package:frontend/features/prediction/domain/entities/prediction_result.dart';
import 'package:frontend/features/prediction/domain/usecases/predict_sleep_quality.dart';
import 'package:frontend/features/prediction/presentation/widgets/aktivitas_fisik_widget.dart';
import 'package:frontend/features/prediction/presentation/widgets/bmi_widget.dart';
import 'package:frontend/features/prediction/presentation/widgets/detak_jantung_widget.dart';
import 'package:frontend/features/prediction/presentation/widgets/durasi_tidur_widget.dart';
import 'package:frontend/features/prediction/presentation/widgets/profil_klinis_widget.dart';
import 'package:frontend/features/prediction/presentation/widgets/tingkat_stres_widget.dart';

class PredictionPage extends ConsumerStatefulWidget {
  const PredictionPage({super.key});

  @override
  ConsumerState<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends ConsumerState<PredictionPage>
    with SingleTickerProviderStateMixin {
  // ── State variabel: nama & tipe mengikuti skema dataset ──
  double _durasiTidur = 7.5;
  int _aktivitasFisikIndex = 1; // 0 Ringan, 1 Sedang, 2 Intensif -> menit
  double _tingkatStres = 4;
  int _detakJantung = 68;
  int _bmiIndex = 1; // Normal
  String _gender = 'Male';
  int _usia = 30;
  String _pekerjaan = 'Engineer';
  int _langkahHarian = 7000;
  int _sistolik = 120;
  int _diastolik = 80;

  bool _loading = false;
  String? _error;
  PredictionResult? _result;

  /// Indeks widget aktivitas -> menit/hari (skala kolom Physical Activity Level).
  static const List<int> _aktivitasMenit = [20, 45, 90];

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
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverToBoxAdapter(child: _buildHeader(isDarkMode)),
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
                    onChanged: (v) => setState(() => _aktivitasFisikIndex = v),
                  ),
                  const SizedBox(height: 12),
                  TingkatStresWidget(
                    value: _tingkatStres,
                    onChanged: (v) => setState(() => _tingkatStres = v),
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
                  const SizedBox(height: 12),
                  ProfilKlinisWidget(
                    gender: _gender,
                    age: _usia,
                    occupation: _pekerjaan,
                    dailySteps: _langkahHarian,
                    systolicBp: _sistolik,
                    diastolicBp: _diastolik,
                    onGenderChanged: (v) => setState(() => _gender = v),
                    onAgeChanged: (v) => setState(() => _usia = v),
                    onOccupationChanged: (v) => setState(() => _pekerjaan = v),
                    onDailyStepsChanged: (v) => setState(() => _langkahHarian = v),
                    onSystolicChanged: (v) => setState(() => _sistolik = v),
                    onDiastolicChanged: (v) => setState(() => _diastolik = v),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    _buildErrorBox(),
                    const SizedBox(height: 16),
                  ],
                  if (_result != null) ...[
                    _buildResultCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildBioFeedbackPreview(),
                  const SizedBox(height: 20),
                  _buildCtaButton(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _buildError(),
                  ],
                  if (_result != null) ...[
                    const SizedBox(height: 12),
                    _buildResultCard(_result!),
                  ],
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
  Widget _buildHeader(bool isDarkMode) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Logo
          const SleepWiseLogo(size: 38, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                  'Prediksi Kualitas',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ganti Tema',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            icon: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDarkMode ? const Color(0xFF60A5FA) : Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Banner ──
  Widget _buildInfoBanner() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.accentOrange, size: 16),
          const SizedBox(width: 6),
          Text(
            'Didukung Random Forest & Decision Tree',
            style: TextStyle(
              color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'Prediksi Kualitas Tidur',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan metrik harian untuk kalkukasi biomarker istirahat & pemulihan saraf Anda malam ini.',
          style: TextStyle(
            color: colors.onSurfaceVariant,
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
        Expanded(
          child: _buildChip(
            icon: Icons.account_tree_rounded,
            label: 'Random Forest',
            sublabel: 'Ensemble > 92% Akurasi',
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildChip(
            icon: Icons.schema_rounded,
            label: 'Decision Tree',
            sublabel: 'Visual Jalur Transparansi',
            color: AppTheme.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;

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
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
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
            child: Text(
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
          Text(
            'Data Siap Dikomputasi',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Model akan memetakan risiko sleep fragmentation.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
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
              onTap: _loading ? null : _runPrediction,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          const SizedBox(width: 8),
                          Text(
                            _loading
                                ? 'Menghitung...'
                                : 'Prediksi Kualitas Tidur Sekarang',
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
                        '⚡ Dihitung model ML di server • Hasil tersimpan untuk riwayat',
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

  Future<void> _runPrediction() async {
    final input = PredictionInput(
      gender: _gender,
      age: _usia,
      occupation: _pekerjaan,
      sleepDuration: _durasiTidur,
      physicalActivityLevel: _aktivitasMenit[
          _aktivitasFisikIndex.clamp(0, _aktivitasMenit.length - 1).toInt()],
      stressLevel: _tingkatStres.round().clamp(1, 10).toInt(),
      bmiCategory: const ['Underweight', 'Normal', 'Overweight', 'Obese'][
          _bmiIndex.clamp(0, 3).toInt()],
      heartRate: _detakJantung,
      dailySteps: _langkahHarian,
      systolicBp: _sistolik,
      diastolicBp: _diastolik,
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final predict = PredictSleepQuality(ref.read(predictionRepositoryProvider));
      final result = await predict(input);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } on PredictionException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Prediksi gagal: $error';
        _loading = false;
      });
    }
  }

  // ── Kartu hasil inferensi model ──
  Widget _buildResultCard() {
    final result = _result!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.label,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${result.confidencePercent}%',
                style: const TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.guardrailApplied
                ? 'Model memprediksi: ${result.modelLabel} — diturunkan ke "Perlu perhatian" oleh aturan klinis'
                : 'Model: ${result.modelName} • probabilitas predict_proba',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
          const SizedBox(height: 12),
          for (final item in result.recommendations)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: colors.primary, fontSize: 13)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (result.outOfRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input di luar rentang data latih',
                    style: TextStyle(
                      color: AppTheme.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final note in result.outOfRange)
                    Text(
                      '• $note',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
      ),
      child: Text(
        _error!,
        style: const TextStyle(color: AppTheme.error, fontSize: 12, height: 1.4),
      ),
    );
  }
}
