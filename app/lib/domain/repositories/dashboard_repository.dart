import '../model/teacher_dashboard.dart';

abstract interface class DashboardRepository {
  Future<TeacherDashboard> teacherDashboard();
}
