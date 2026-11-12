class UserProfile {
  final String fullName;
  final String username;
  final String email;
  final DateTime birthDate;
  final String gender;
  final String occupation;
  final String avatarId;

  const UserProfile({
    required this.fullName,
    required this.username,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.occupation,
    this.avatarId = 'avatar_1',
  });

  factory UserProfile.initial() {
    return UserProfile(
      fullName: 'Sarah Nabila',
      username: 'sarahnabila',
      email: 'sarah.nabila@kampus.ac.id',
      birthDate: DateTime(2002, 5, 14),
      gender: 'Perempuan',
      occupation: 'Mahasiswa',
      avatarId: 'avatar_1',
    );
  }

  String get birthDateFormatted {
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
    return '${birthDate.day} ${months[birthDate.month - 1]} ${birthDate.year}';
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    DateTime? birthDate,
    String? gender,
    String? occupation,
    String? avatarId,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}

