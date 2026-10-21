import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/sleepwise_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _isObscure = false;
  bool _agreeTerms = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;
    final badgeAccent = isDarkMode
        ? const Color(0xFF34D399)
        : const Color(0xFF047857);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppAuthColors.iconBg(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                          color: isDarkMode
                              ? const Color(0xFF60A5FA)
                              : Colors.amber,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppAuthColors.containerBg(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppAuthColors.containerBorder(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SleepWiseLogo(size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'SleepWise ML',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Green Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badgeAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.nightlight_round, size: 14, color: badgeAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Circadian Rhythm Sanctuary',
                      style: TextStyle(
                        fontSize: 12,
                        color: badgeAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Form Field 1: Nama Lengkap
              _buildFormLabel(context, Icons.person_outline, 'Nama Lengkap'),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: 'Sarah Nabila'),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: _buildInputDecoration(
                  context: context,
                  suffixIcon: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Form Field 2: Alamat Email
              _buildFormLabel(context, Icons.email_outlined, 'Alamat Email'),
              const SizedBox(height: 8),
              TextField(
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: _buildInputDecoration(
                  context: context,
                  hintText: 'email@domain.com',
                ),
              ),
              const SizedBox(height: 18),

              // Form Field 3: Kata Sandi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFormLabel(context, Icons.lock_outline, 'Kata Sandi'),
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'Kuat',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: 'NightRest#2025!'),
                obscureText: _isObscure,
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: _buildInputDecoration(
                  context: context,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Password Strength Bars
              Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Requirement Check
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: badgeAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kombinasi huruf besar, angka & karakter khusus terpenuhi',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Form Field 4: Konfirmasi Kata Sandi
              _buildFormLabel(
                context,
                Icons.shield_outlined,
                'Konfirmasi Kata Sandi',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: 'NightRest#2025!'),
                obscureText: true,
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                decoration: _buildInputDecoration(
                  context: context,
                  suffixIcon: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _agreeTerms,
                      activeColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() => _agreeTerms = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text:
                                'Ketentuan Layanan & Kebijakan Privasi Data Kesehatan SleepWise',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' yang dienkripsi end-to-end.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daftar Akun SleepWise',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider ATAU
              Row(
                children: [
                  Expanded(child: Divider(color: colors.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'ATAU',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.outline)),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol Google
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppAuthColors.containerBg(context),
                    foregroundColor: colors.onSurface,
                    side: BorderSide(
                      color: AppAuthColors.containerBorder(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text(
                              'G',
                              style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Daftar Cepat dengan Google',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Footer Link ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah memiliki akun? ',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(BuildContext context, IconData icon, String title) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    String? hintText,
    Widget? suffixIcon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppAuthColors.inputFill(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppAuthColors.inputBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary),
      ),
    );
  }
}
