import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/view/stateManager/auth/auth_state.dart';

AppUser _user(UserRole role, {bool mustChangePassword = false}) =>
    AppUser(id: '1', role: role, username: 'u', firstName: 'F', lastName: 'L', mustChangePassword: mustChangePassword);

void main() {
  test('while the session is restored, everything waits on the splash screen', () {
    expect(authRedirect(const AuthUnknown(), Routes.teacherHome), Routes.splash);
    expect(authRedirect(const AuthUnknown(), Routes.splash), isNull);
  });

  test('signed out always lands on the login screen', () {
    expect(authRedirect(const AuthSignedOut(), Routes.teacherPlanning), Routes.login);
    expect(authRedirect(const AuthSignedOut(), Routes.login), isNull);
  });

  test('each role opens its own home and stays in its own area', () {
    expect(authRedirect(AuthSignedIn(_user(UserRole.teacher)), Routes.login), Routes.teacherHome);
    expect(authRedirect(AuthSignedIn(_user(UserRole.teacher)), Routes.teacherPlanning), isNull);
    expect(authRedirect(AuthSignedIn(_user(UserRole.student)), Routes.splash), Routes.studentHome);
    expect(authRedirect(AuthSignedIn(_user(UserRole.parent)), Routes.login), Routes.parentOverview);
    expect(authRedirect(AuthSignedIn(_user(UserRole.admin)), Routes.login), Routes.adminTeachers);
    expect(authRedirect(AuthSignedIn(_user(UserRole.admin)), Routes.adminTeachers), isNull);
  });

  test('a role can never open another role screen', () {
    expect(authRedirect(AuthSignedIn(_user(UserRole.student)), Routes.teacherHome), Routes.studentHome);
    expect(authRedirect(AuthSignedIn(_user(UserRole.parent)), Routes.studentResults), Routes.parentOverview);
    expect(authRedirect(AuthSignedIn(_user(UserRole.teacher)), Routes.parentOverview), Routes.teacherHome);
    // The owner of the platform never enters a teacher's space, and no one else reaches the dashboard.
    expect(authRedirect(AuthSignedIn(_user(UserRole.admin)), Routes.teacherStudents), Routes.adminTeachers);
    expect(authRedirect(AuthSignedIn(_user(UserRole.teacher)), Routes.adminTeachers), Routes.teacherHome);
    expect(authRedirect(AuthSignedIn(_user(UserRole.parent)), Routes.adminTeachers), Routes.parentOverview);
  });

  test('a temporary password must be replaced before anything else', () {
    final user = _user(UserRole.student, mustChangePassword: true);
    expect(authRedirect(AuthSignedIn(user), Routes.studentHome), Routes.choosePassword);
    expect(authRedirect(AuthSignedIn(user), Routes.choosePassword), isNull);
  });
}
