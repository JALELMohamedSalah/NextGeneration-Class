import '../../domain/repositories/admin_repository.dart';
import '../../view/stateManager/admin/teachers_cubit.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../../data/repository/evaluation_repository_impl.dart';
import '../../data/remote/evaluation_api.dart';
import '../../data/repository/admin_repository_impl.dart';
import '../../data/remote/admin_api.dart';
import '../../data/remote/notifications_api.dart';
import '../../data/repository/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../view/stateManager/notifications/notifications_cubit.dart';
import '../../view/stateManager/search/search_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/remote/auth_api.dart';
import '../../data/remote/content_api.dart';
import '../../data/remote/homework_api.dart';
import '../../data/remote/comments_api.dart';
import '../../data/remote/results_api.dart';
import '../../data/remote/search_api.dart';
import '../../data/remote/student_import_api.dart';
import '../../data/repository/content_repository_impl.dart';
import '../../data/repository/homework_repository_impl.dart';
import '../../data/repository/comment_repository_impl.dart';
import '../../data/repository/results_repository_impl.dart';
import '../../data/repository/search_repository_impl.dart';
import '../../data/repository/student_import_repository_impl.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/homework_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/results_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/repositories/student_import_repository.dart';
import '../../view/stateManager/library/library_cubit.dart';
import '../platform/file_chooser.dart';
import '../platform/document_printer.dart';
import '../platform/file_opener.dart';
import '../platform/photo_source.dart';
import '../../data/files/scan_processor_impl.dart';
import '../../domain/services/scan_processor.dart';
import '../../data/remote/planning_api.dart';
import '../../data/remote/school_api.dart';
import '../../data/remote/students_api.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../data/repository/dashboard_repository_impl.dart';
import '../../data/repository/group_repository_impl.dart';
import '../../data/repository/planning_repository_impl.dart';
import '../../data/repository/reference_repository_impl.dart';
import '../../data/repository/student_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/planning_repository.dart';
import '../../domain/repositories/reference_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../view/stateManager/auth/auth_cubit.dart';
import '../../view/stateManager/auth/auth_state.dart';
import '../../view/stateManager/groups/groups_cubit.dart';
import '../../view/stateManager/language/language_cubit.dart';
import '../../view/stateManager/login/login_cubit.dart';
import '../../view/stateManager/password/change_password_cubit.dart';
import '../../view/stateManager/reference/reference_cubit.dart';
import '../../view/stateManager/settings/subjects_settings_cubit.dart';
import '../../view/stateManager/students/students_cubit.dart';
import '../../view/stateManager/teacher_home/teacher_home_cubit.dart';
import '../config/app_config.dart';
import '../l10n/language_store.dart';
import '../l10n/tunis_time.dart';
import '../network/dio_client.dart';
import '../network/token_store.dart';
import '../platform/link_opener.dart';
import 'service_locator.dart';

export 'service_locator.dart';

void configureDependencies(AppConfig config) {
  sl.reset();

  // ── Core ──
  sl.registerSingleton<AppConfig>(config);
  sl.registerSingleton<Now>(DateTime.now);
  sl.registerLazySingleton<LinkOpener>(UrlLauncherLinkOpener.new);
  sl.registerLazySingleton<FileChooser>(FilePickerChooser.new);
  sl.registerLazySingleton<FileOpener>(UrlLauncherFileOpener.new);
  sl.registerLazySingleton<DocumentPrinter>(PrintingDocumentPrinter.new);
  sl.registerLazySingleton<PhotoSource>(ImagePickerPhotoSource.new);
  sl.registerLazySingleton<ScanProcessor>(ScanProcessorImpl.new);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<TokenStore>(() => TokenStore(sl.get()));
  sl.registerLazySingleton<LanguageStore>(() => LanguageStore(SharedPreferencesAsync()));
  sl.registerLazySingleton<LanguageCubit>(() => LanguageCubit(sl.get()));
  sl.registerLazySingleton<DioClient>(
    () => DioClient(config: config, tokens: sl.get(), language: () => sl.get<LanguageCubit>().state.code),
  );

  // ── Auth ──
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(api: sl.get(), tokens: sl.get()));
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl.get()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl.get(), sl.get()));
  sl.registerFactory<ChangePasswordCubit>(() => ChangePasswordCubit(sl.get()));

  // ── School: reference lists, students, groups, planning ──
  sl.registerLazySingleton<SchoolApi>(() => SchoolApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<StudentsApi>(() => StudentsApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<PlanningApi>(() => PlanningApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<ReferenceRepository>(() => ReferenceRepositoryImpl(sl.get()));
  sl.registerLazySingleton<StudentRepository>(() => StudentRepositoryImpl(sl.get()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl.get()));
  sl.registerLazySingleton<PlanningRepository>(() => PlanningRepositoryImpl(sl.get()));
  sl.registerLazySingleton<EvaluationApi>(() => EvaluationApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<EvaluationRepository>(() => EvaluationRepositoryImpl(sl.get()));
  sl.registerLazySingleton<AdminApi>(() => AdminApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl.get()));
  sl.registerFactory<TeachersCubit>(() => TeachersCubit(sl.get()));
  sl.registerLazySingleton<NotificationsApi>(() => NotificationsApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(sl.get()));
  sl.registerFactory<NotificationsCubit>(() => NotificationsCubit(sl.get(), poll: const Duration(minutes: 1)));
  sl.registerFactory<ReferenceCubit>(() => ReferenceCubit(sl.get()));
  sl.registerFactory<GroupsCubit>(() => GroupsCubit(sl.get()));
  sl.registerFactory<StudentsCubit>(() => StudentsCubit(sl.get()));
  sl.registerFactory<SubjectsSettingsCubit>(() => SubjectsSettingsCubit(sl.get()));

  // ── Contents: the library, Cours, the viewer ──
  sl.registerLazySingleton<ContentApi>(() => ContentApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<ContentRepository>(() => ContentRepositoryImpl(sl.get(), sl.get()));
  sl.registerFactory<LibraryCubit>(() => LibraryCubit(sl.get()));

  // ── Homework: given by the teacher, sent by the pupil or the parent ──
  sl.registerLazySingleton<HomeworkApi>(() => HomeworkApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<HomeworkRepository>(() => HomeworkRepositoryImpl(sl.get(), sl.get()));
  sl.registerLazySingleton<ResultsApi>(() => ResultsApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<StudentImportApi>(() => StudentImportApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<SearchApi>(() => SearchApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl.get()));
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl.get()));
  sl.registerLazySingleton<StudentImportRepository>(() => StudentImportRepositoryImpl(sl.get()));
  sl.registerLazySingleton<ResultsRepository>(() => ResultsRepositoryImpl(sl.get()));
  sl.registerLazySingleton<CommentsApi>(() => CommentsApi(sl.get<DioClient>().dio));
  sl.registerLazySingleton<CommentRepository>(() => CommentRepositoryImpl(sl.get()));

  // ── Teacher home ──
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(sl.get(), sl.get(), now: sl.get<Now>()));
  sl.registerFactory<TeacherHomeCubit>(() => TeacherHomeCubit(sl.get()));
}

/// Links the session to the rest of the app, once at start.
void startSession(AuthCubit auth, LanguageCubit language) {
  DioClient.onSessionExpired = auth.sessionExpired;
  // The server writes its own messages (push, email) in the user's last language.
  language.stream.listen((value) {
    if (auth.state is AuthSignedIn) sl.get<AuthRepository>().updateLanguage(value).ignore();
  });
}
