import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../widgets/profile_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  late DateTime _birthDate;
  late String _gender;
  late String _occupation;
  late String _avatarId;

  final List<String> _occupationOptions = const [
    'Mahasiswa',
    'Pekerja Shift',
    'Karyawan Kantor',
    'Tenaga Medis',
    'Wiraswasta',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _fullNameController = TextEditingController(text: profile.fullName);
    _usernameController = TextEditingController(text: profile.username);
    _emailController = TextEditingController(text: profile.email);

    _birthDate = profile.birthDate;
    _gender = profile.gender;
    _occupation = _occupationOptions.contains(profile.occupation)
        ? profile.occupation
        : _occupationOptions.first;
    _avatarId = profile.avatarId;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primary,
                    onPrimary: Colors.white,
                    surface: Color(0xFF161B22),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Color(0xFF161B22),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTheme.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1F2937),
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _openAvatarPicker() {
    AvatarPickerSheet.show(
      context: context,
      currentAvatarId: _avatarId,
      onAvatarSelected: (newId) {
        setState(() {
          _avatarId = newId;
        });
      },
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updated = UserProfile(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim().replaceAll('@', ''),
      email: _emailController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      occupation: _occupation,
      avatarId: _avatarId,
    );

    ref.read(userProfileProvider.notifier).updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Profil berhasil diperbarui ✨'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = colors.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
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
                    Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
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
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar Center Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _openAvatarPicker,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ProfileAvatar(
                              avatarId: _avatarId,
                              radius: 46,
                              showBorder: true,
                              borderColor: AppTheme.primary,
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode
                                      ? AppTheme.background
                                      : Colors.white,
                                  width: 2.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _openAvatarPicker,
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        label: const Text(
                          'Ganti Foto Profil',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Data Utama Akun
                _buildSectionTitle(context, 'Informasi Pribadi'),
                const SizedBox(height: 14),

                // Field 1: Nama Lengkap
                _buildFormLabel(context, Icons.person_outline, 'Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: colors.onSurface, fontSize: 14),
                  decoration: _buildInputDecoration(
                    context: context,
                    hintText: 'Masukkan nama lengkap',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Field 2: Username
                _buildFormLabel(
                  context,
                  Icons.alternate_email_rounded,
                  'Username',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: colors.onSurface, fontSize: 14),
                  decoration: _buildInputDecoration(
                    context: context,
                    hintText: 'username',
                    prefixText: '@ ',
                    prefixStyle: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (val.trim().contains(' ')) {
                      return 'Username tidak boleh mengandung spasi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Field 3: Alamat Email
                _buildFormLabel(context, Icons.email_outlined, 'Alamat Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.onSurface, fontSize: 14),
                  decoration: _buildInputDecoration(
                    context: context,
                    hintText: 'email@domain.com',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Alamat email tidak boleh kosong';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Section 2: Data Sirkadian & Demografi
                _buildSectionTitle(context, 'Data Sirkadian & Demografi'),
                const SizedBox(height: 14),

                // Field 4: Tanggal Lahir
                _buildFormLabel(
                  context,
                  Icons.calendar_today_rounded,
                  'Tanggal Lahir',
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppAuthColors.inputFill(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppAuthColors.inputBorder(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatBirthDate(_birthDate),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Field 5: Jenis Kelamin
                _buildFormLabel(
                  context,
                  Icons.wc_rounded,
                  'Jenis Kelamin',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderOption(
                        context: context,
                        label: 'Perempuan',
                        icon: Icons.female_rounded,
                        isSelected: _gender == 'Perempuan',
                        onTap: () => setState(() => _gender = 'Perempuan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderOption(
                        context: context,
                        label: 'Laki-laki',
                        icon: Icons.male_rounded,
                        isSelected: _gender == 'Laki-laki',
                        onTap: () => setState(() => _gender = 'Laki-laki'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Field 6: Pekerjaan
                _buildFormLabel(
                  context,
                  Icons.work_outline_rounded,
                  'Pekerjaan / Aktivitas',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _occupation,
                  dropdownColor: isDarkMode
                      ? const Color(0xFF161B22)
                      : Colors.white,
                  style: TextStyle(color: colors.onSurface, fontSize: 14),
                  decoration: _buildInputDecoration(
                    context: context,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  items: _occupationOptions.map((occ) {
                    return DropdownMenuItem<String>(
                      value: occ,
                      child: Text(occ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _occupation = val);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurfaceVariant,
                      side: BorderSide(
                        color: AppAuthColors.containerBorder(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: colors.primary,
        letterSpacing: 0.5,
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

  Widget _buildGenderOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.12)
              : AppAuthColors.inputFill(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppAuthColors.inputBorder(context),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    String? hintText,
    String? prefixText,
    TextStyle? prefixStyle,
    Widget? suffixIcon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      prefixText: prefixText,
      prefixStyle: prefixStyle,
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
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
      ),
    );
  }

  String _formatBirthDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
