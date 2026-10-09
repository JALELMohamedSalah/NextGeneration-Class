import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/repositories/auth_repository.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState({this.submitting = false, this.failure, this.done = false});

  final bool submitting;
  final ApiFailure? failure;
  final bool done;

  @override
  List<Object?> get props => [submitting, failure?.code, failure?.message, done];
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._repository) : super(const ChangePasswordState());

  final AuthRepository _repository;

  Future<void> submit({required String currentPassword, required String newPassword}) async {
    if (state.submitting) return;
    emit(const ChangePasswordState(submitting: true));
    try {
      await _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      emit(const ChangePasswordState(done: true));
    } on Object catch (error) {
      emit(ChangePasswordState(failure: ApiFailure.from(error)));
    }
  }
}
