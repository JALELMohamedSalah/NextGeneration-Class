import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/repositories/auth_repository.dart';
import 'package:ngclass/view/stateManager/auth/auth_cubit.dart';
import 'package:ngclass/view/stateManager/auth/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _student = AppUser(
  id: '1',
  role: UserRole.student,
  username: 'eleve.demo',
  firstName: 'Adam',
  lastName: 'Gharbi',
  mustChangePassword: true,
);

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  blocTest<AuthCubit, AuthState>(
    'a saved session reopens signed in',
    build: () {
      when(() => repository.restoreSession()).thenAnswer((_) async => _student);
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restore(),
    expect: () => [const AuthSignedIn(_student)],
  );

  blocTest<AuthCubit, AuthState>(
    'no session, or a failure while restoring, means signed out',
    build: () {
      when(() => repository.restoreSession()).thenThrow(StateError('boom'));
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restore(),
    expect: () => [const AuthSignedOut()],
  );

  blocTest<AuthCubit, AuthState>(
    'choosing a password lifts the temporary-password gate',
    build: () => AuthCubit(repository),
    seed: () => const AuthSignedIn(_student),
    act: (cubit) => cubit.passwordChanged(),
    expect: () => [AuthSignedIn(_student.copyWith(mustChangePassword: false))],
  );

  blocTest<AuthCubit, AuthState>(
    'a session refused by the server signs out',
    build: () => AuthCubit(repository),
    seed: () => const AuthSignedIn(_student),
    act: (cubit) => cubit.sessionExpired(),
    expect: () => [const AuthSignedOut()],
  );
}
