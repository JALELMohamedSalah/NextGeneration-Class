import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/teacher_dashboard.dart';
import '../../../domain/repositories/dashboard_repository.dart';

sealed class TeacherHomeState extends Equatable {
  const TeacherHomeState();

  @override
  List<Object?> get props => [];
}

final class TeacherHomeLoading extends TeacherHomeState {
  const TeacherHomeLoading();
}

final class TeacherHomeLoaded extends TeacherHomeState {
  const TeacherHomeLoaded(this.dashboard);

  final TeacherDashboard dashboard;

  @override
  List<Object?> get props => [dashboard];
}

final class TeacherHomeFailed extends TeacherHomeState {
  const TeacherHomeFailed(this.failure);

  final ApiFailure failure;

  @override
  List<Object?> get props => [failure.code, failure.message];
}

/// "Ma journée": loads the dashboard, and again on demand.
class TeacherHomeCubit extends Cubit<TeacherHomeState> {
  TeacherHomeCubit(this._repository) : super(const TeacherHomeLoading());

  final DashboardRepository _repository;

  Future<void> load() async {
    emit(const TeacherHomeLoading());
    try {
      emit(TeacherHomeLoaded(await _repository.teacherDashboard()));
    } on Object catch (error) {
      emit(TeacherHomeFailed(ApiFailure.from(error)));
    }
  }
}
