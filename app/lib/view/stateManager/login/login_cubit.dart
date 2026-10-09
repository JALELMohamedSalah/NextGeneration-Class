import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../auth/auth_cubit.dart';

class LoginState extends Equatable {
  const LoginState({this.submitting = false, this.failure});

  final bool submitting;
  final ApiFailure? failure;

  @override
  List<Object?> get props => [submitting, failure?.code, failure?.message];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository, this._auth) : super(const LoginState());

  final AuthRepository _repository;
  final AuthCubit _auth;

  Future<void> submit({required String login, required String password}) async {
    if (state.submitting) return;
    emit(const LoginState(submitting: true));
    try {
      final user = await _repository.login(login: login.trim(), password: password);
      emit(const LoginState());
      _auth.signedIn(user);
    } on Object catch (error) {
      emit(LoginState(failure: ApiFailure.from(error)));
    }
  }
}
