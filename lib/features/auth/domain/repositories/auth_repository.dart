import 'package:beesports/features/auth/domain/entities/user_entity.dart';

/// Abstract auth repository interface.
abstract class AuthRepository {
  /// Sign up with email and password. Only @binus.ac.id allowed.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Verify OTP sent to email.
  Future<UserEntity> verifyOtp({
    required String email,
    required String token,
  });

  /// Sign in with email and password.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user.
  Future<void> signOut();

  /// Get current authenticated user, or null.
  Future<UserEntity?> getCurrentUser();

  /// Save/update user profile after onboarding.
  Future<void> saveUserProfile(UserEntity user);

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
