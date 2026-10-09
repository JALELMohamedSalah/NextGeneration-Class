import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/app_user.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Who is signed in. The router follows this state to open the right role space.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthUnknown());

  final AuthRepository _repository;

  AppUser? get user => switch (state) {
    AuthSignedIn(:final user) => user,
    _ => null,
  };

  Future<void> restore() async {
    try {
      final user = await _repository.restoreSession();
      emit(user == null ? const AuthSignedOut() : AuthSignedIn(user));
    } on Object {
      emit(const AuthSignedOut());
    }
  }

  void signedIn(AppUser user) => emit(AuthSignedIn(user));

  void passwordChanged() {
    final current = user;
    if (current != null) emit(AuthSignedIn(current.copyWith(mustChangePassword: false)));
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthSignedOut());
  }

  /// The server refused the session (account reset or disabled).
  void sessionExpired() {
    if (state is AuthSignedIn) emit(const AuthSignedOut());
  }
}
