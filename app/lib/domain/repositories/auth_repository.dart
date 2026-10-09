import '../../core/l10n/app_language.dart';
import '../model/app_user.dart';

/// Every method throws an ApiFailure when the call fails.
abstract interface class AuthRepository {
  /// [login] is a username or a phone number.
  Future<AppUser> login({required String login, required String password});

  /// The signed-in user at app start, or null when there is no session. Without network the
  /// last known user is returned: only the server can end a session.
  Future<AppUser?> restoreSession();

  Future<void> logout();

  Future<void> changePassword({required String currentPassword, required String newPassword});

  /// Tells the server which language its own messages (push, email) should use.
  Future<void> updateLanguage(AppLanguage language);
}
