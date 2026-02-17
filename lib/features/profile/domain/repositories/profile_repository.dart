import 'package:beesports/features/profile/domain/entities/profile_entity.dart';

/// Abstract profile repository interface.
abstract class ProfileRepository {
  /// Fetch profile by user ID.
  Future<ProfileEntity?> getProfile(String userId);

  /// Update profile data.
  Future<void> updateProfile(ProfileEntity profile);

  /// Complete onboarding with sport preferences and skill levels.
  Future<void> completeOnboarding({
    required String userId,
    required String nim,
    required String campus,
    required List<String> sportPreferences,
    required Map<String, String> skillLevels,
  });
}
