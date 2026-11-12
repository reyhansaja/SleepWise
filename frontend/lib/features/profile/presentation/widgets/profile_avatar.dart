import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AvatarData {
  final String id;
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const AvatarData({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class AvatarRegistry {
  static const List<AvatarData> all = [
    AvatarData(
      id: 'avatar_1',
      name: 'Default',
      icon: Icons.person_rounded,
      primaryColor: Color(0xFF7C5CFC),
      secondaryColor: Color(0xFF9B7FFF),
    ),
    AvatarData(
      id: 'avatar_2',
      name: 'Sirkadian',
      icon: Icons.nightlight_round,
      primaryColor: Color(0xFF4ECDC4),
      secondaryColor: Color(0xFF2C3E50),
    ),
    AvatarData(
      id: 'avatar_3',
      name: 'Sanctuary',
      icon: Icons.face_3_rounded,
      primaryColor: Color(0xFFFF6B9D),
      secondaryColor: Color(0xFF7C5CFC),
    ),
    AvatarData(
      id: 'avatar_4',
      name: 'Explorer',
      icon: Icons.face_rounded,
      primaryColor: Color(0xFF54A0FF),
      secondaryColor: Color(0xFF4ECDC4),
    ),
    AvatarData(
      id: 'avatar_5',
      name: 'Researcher',
      icon: Icons.psychology_rounded,
      primaryColor: Color(0xFFFF9F43),
      secondaryColor: Color(0xFFFF6B9D),
    ),
    AvatarData(
      id: 'avatar_6',
      name: 'Zen Mind',
      icon: Icons.spa_rounded,
      primaryColor: Color(0xFF3FB950),
      secondaryColor: Color(0xFF4ECDC4),
    ),
  ];

  static AvatarData getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => all.first,
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String avatarId;
  final double radius;
  final bool showBorder;
  final Color? borderColor;

  const ProfileAvatar({
    super.key,
    required this.avatarId,
    this.radius = 36,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = AvatarRegistry.getById(avatarId);
    final border = borderColor ?? AppTheme.primary;

    return Container(
      padding: showBorder ? const EdgeInsets.all(3) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: border, width: 2) : null,
      ),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [avatar.primaryColor, avatar.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: avatar.primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          avatar.icon,
          size: radius * 1.05,
          color: Colors.white,
        ),
      ),
    );
  }
}

