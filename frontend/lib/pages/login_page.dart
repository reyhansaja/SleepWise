import 'package:flutter/material.dart';
import '../widgets/sleepwise_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Aplikasi
                const SleepWiseLogo(size: 76),
                const SizedBox(height: 20),

                // Title + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SleepWise',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F293A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E4C5B)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: Color(0xFF2DD4BF)),
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

                const Text(
                  'Selamat Datang Kembali',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Masuk untuk memantau ritme sirkadian dan\nprediksi kualitas istirahat Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Form Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111726),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Email
                      _buildInputLabel('Email / Akun Kampus'),
                      const SizedBox(height: 8),
                      TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          hintText: 'nama@kampus.ac.id atau email',
                          prefixIcon: Icons.alternate_email_rounded,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Label Password
                      _buildInputLabel('Kata Sandi'),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _isObscure,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          hintText: '••••••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                                style: TextStyle(color: Colors.grey[300], fontSize: 13),
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
                          onPressed: () => Navigator.pushNamed(context, '/history'),
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
                              Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider ATAU
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[800])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'ATAU MASUK DENGAN',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[800])),
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
                            backgroundColor: const Color(0xFF182032),
                            side: const BorderSide(color: Color(0xFF26334D)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                height: 18,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 24),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Lanjutkan dengan Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
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
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _buildInputLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFFE2E8F0),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[500], size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF161D2F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF232D42)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF818CF8)),
      ),
    );
  }
}