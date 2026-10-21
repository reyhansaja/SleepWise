import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/core/widgets/sleepwise_logo.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _rememberMe = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Tombol Toggle Mode Terang/Gelap di Kiri Atas ──
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppAuthColors.iconBg(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppAuthColors.containerBorder(context),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: isDarkMode
                              ? const Color(0xFF60A5FA)
                              : Colors.amber,
                          size: 20,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggle();
                        },
                        tooltip: 'Ganti Tema',
                      ),
                    ),
                  ),
                ),

                // Logo Aplikasi
                const SleepWiseLogo(size: 76),
                const SizedBox(height: 20),

                // Title + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SleepWise',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppAuthColors.textMain(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF0F293A)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF1E4C5B)
                              : const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Color(0xFF2DD4BF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ML Analytics',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2DD4BF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  'Selamat Datang Kembali',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppAuthColors.textMain(context),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Masuk untuk memantau ritme sirkadian dan\nprediksi kualitas istirahat Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Form Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppAuthColors.containerBg(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppAuthColors.containerBorder(context),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel('Email / Akun Kampus', context),
                      const SizedBox(height: 8),
                      TextField(
                        style: TextStyle(
                          color: AppAuthColors.textMain(context),
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'nama@kampus.ac.id atau email',
                          prefixIcon: Icons.alternate_email_rounded,
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _buildInputLabel('Kata Sandi', context),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _isObscure,
                        style: TextStyle(
                          color: AppAuthColors.textMain(context),
                          fontSize: 14,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: '••••••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          context: context,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _isObscure = !_isObscure);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ingat saya & Lupa Kata Sandi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: const Color(0xFF818CF8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    setState(() => _rememberMe = val ?? false);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat saya',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lupa Kata Sandi?',
                              style: TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/main');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF818CF8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk ke Akun',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Footer Link ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: AppAuthColors.textMain(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        color: AppAuthColors.textMain(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    required BuildContext context,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[500], size: 20)
          : null,
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
        borderSide: const BorderSide(color: Color(0xFF818CF8)),
      ),
    );
  }
}
