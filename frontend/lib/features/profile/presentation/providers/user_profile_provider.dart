import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => UserProfile.initial();

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }
}

