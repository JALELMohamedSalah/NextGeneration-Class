// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'NextGeneration Class';

  @override
  String get appShortName => 'NG Class';

  @override
  String get tagline => 'تعليم، متابعة، تقدّم.';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get loginSubtitle => 'سجّل الدخول بالمعرّف الذي قدّمته لك أستاذتك.';

  @override
  String get loginIdentifierLabel => 'المعرّف أو رقم الهاتف';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginSubmit => 'دخول';

  @override
  String get loginIdentifierRequired => 'أدخل المعرّف أو رقم الهاتف.';

  @override
  String get loginPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get loginForgotHint =>
      'نسيت كلمة المرور؟ اطلب من أستاذتك إعادة تعيينها.';

  @override
  String get loginFeaturePlanning => 'الجدول والحضور';

  @override
  String get loginFeatureWork => 'الفروض والإصلاح';

  @override
  String get loginFeatureProgress => 'متابعة التقدّم';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get errorNetwork =>
      'تعذّر الاتصال بالخادم. تحقّق من اتصالك بالإنترنت.';

  @override
  String get errorUnknown => 'حدث خطأ. يرجى إعادة المحاولة.';

  @override
  String get navTeacherHome => 'يومي';

  @override
  String get navPlanning => 'الجدول';

  @override
  String get navStudents => 'التلاميذ';

  @override
  String get navContents => 'المحتوى';

  @override
  String get navAssignments => 'الفروض';

  @override
  String get navAnnouncements => 'الإعلانات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navMore => 'المزيد';

  @override
  String get navStudentHome => 'الرئيسية';

  @override
  String get navCourses => 'الدروس';

  @override
  String get navResults => 'النتائج';

  @override
  String get navParentOverview => 'نظرة عامة';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String greeting(String firstName) {
    return 'مرحبًا $firstName';
  }

  @override
  String get homeToday => 'اليوم';

  @override
  String get homeToCorrect => 'للإصلاح';

  @override
  String get homeMissing => 'أعمال لم تُسلَّم';

  @override
  String get homeUpcoming => 'قادم';

  @override
  String get emptyToday => 'لا توجد حصص اليوم.';

  @override
  String get emptyToCorrect => 'لا شيء للإصلاح. يومًا سعيدًا!';

  @override
  String get emptyMissing => 'تمّ تسليم كل الفروض.';

  @override
  String get emptyUpcoming => 'لا شيء مبرمج في الأيام السبعة القادمة.';

  @override
  String get quickCreate => 'إنشاء';

  @override
  String get quickSession => 'حصة';

  @override
  String get quickAssignment => 'فرض';

  @override
  String get quickSeries => 'سلسلة';

  @override
  String get comingSoonMessage => 'سيتوفّر هذا القسم في نسخة قادمة من التطبيق.';

  @override
  String get accountMenu => 'حسابي';

  @override
  String get language => 'اللغة';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get roleTeacher => 'الأستاذة';

  @override
  String get roleStudent => 'تلميذ';

  @override
  String get roleParent => 'وليّ';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get temporaryPassword => 'كلمة المرور المؤقتة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordRule => '8 أحرف على الأقل، منها حروف وأرقام.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordChanged => 'تمّ تغيير كلمة المرور.';

  @override
  String get fieldRequired => 'هذا الحقل إجباري.';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get mustChangePasswordTitle => 'اختر كلمة المرور الخاصة بك';

  @override
  String get mustChangePasswordMessage =>
      'قدّمت لك أستاذتك كلمة مرور مؤقتة. اختر كلمة مرور جديدة للمتابعة.';

  @override
  String get nextSession => 'الحصة القادمة';

  @override
  String get noSessionPlanned => 'لا توجد حصة مبرمجة حاليًا.';

  @override
  String get toDo => 'للإنجاز';

  @override
  String get nothingToDo => 'لا شيء للإنجاز حاليًا.';

  @override
  String get latestResults => 'آخر النتائج';

  @override
  String get noGradeYet => 'لا توجد أعداد بعد.';

  @override
  String get attendance => 'الحضور';

  @override
  String get assignments => 'الفروض';

  @override
  String get parentNoChild =>
      'لا يوجد أي طفل مرتبط بهذا الحساب. يرجى التواصل مع الأستاذة.';

  @override
  String get parentNoDataYet => 'ستظهر المعلومات هنا بداية من الحصص الأولى.';

  @override
  String get loginOverline => 'فضاء خاص';

  @override
  String get loginWelcome => 'مرحبًا بعودتك';

  @override
  String get loginBrandLine => 'الفضاء الخاص بأستاذتك، لتلاميذها وأوليائهم.';

  @override
  String get loginFeaturePlanningText =>
      'الحصص وروابط Meet وتسجيل الحضور بلمسة واحدة.';

  @override
  String get loginFeatureWorkText =>
      'الأعمال المسلّمة وقائمة الإصلاح والأعداد على 20.';

  @override
  String get loginFeatureProgressText => 'يفهم الأولياء كل شيء في دقيقة واحدة.';

  @override
  String get firstLoginOverline => 'أول دخول';

  @override
  String get footerCopyright => '© NextGeneration Class';

  @override
  String get languageToggleShort => 'FR · ع';

  @override
  String get searchPlaceholder => 'ابحث عن تلميذ أو محتوى…';

  @override
  String get myGroups => 'مجموعاتي';

  @override
  String get homeSummaryEmpty =>
      'لا شيء مبرمج حاليًا. أضف تلاميذك وحصصك لتمتلئ صفحة يومك.';

  @override
  String get heroToday => 'اليوم';

  @override
  String get heroFreeDayTitle => 'يوم فارغ';

  @override
  String get heroFreeDayText => 'لا توجد حصص مبرمجة اليوم.';

  @override
  String get planSession => 'برمجة حصة';

  @override
  String get quickQcm => 'اختيار من متعدد';

  @override
  String get quickImport => 'استيراد';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get emptyComment => 'لا توجد ملاحظات حاليًا.';

  @override
  String get teacherNote => 'كلمة الأستاذة';

  @override
  String get noValue => '—';

  @override
  String releaseBadge(int number) {
    return 'النسخة $number';
  }

  @override
  String get comingPlanning =>
      'جدول الأسبوع والحصص المتكررة وروابط Meet والحضور.';

  @override
  String get comingStudents =>
      'التلاميذ والأولياء والمجموعات والدروس الخصوصية مع معرّفاتهم.';

  @override
  String get comingAssignments => 'الفروض وما يسلّمه التلاميذ وقائمة الإصلاح.';

  @override
  String get comingAnnouncements => 'إعلانات للمجموعات والتلاميذ والأولياء.';

  @override
  String get comingStudentAssignments => 'فروضك واختباراتك وسلاسلك مع آجالها.';

  @override
  String get comingStudentPlanning => 'حصصك القادمة، حضوريًا أو عن بعد.';

  @override
  String get comingResults => 'أعدادك والملاحظات وتقدّمك.';

  @override
  String get comingParentPlanning => 'الحصص القادمة لطفلك.';

  @override
  String daySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      many: '$count حصة',
      few: '$count حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
      zero: 'لا حصص',
    );
    return '$_temp0';
  }

  @override
  String childThisWeek(String name) {
    return '$name هذا الأسبوع';
  }

  @override
  String get average => 'المعدّل';

  @override
  String get lastGrade => 'آخر عدد';

  @override
  String get notYet => 'ليس بعد';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get delete => 'حذف';

  @override
  String get optional => 'اختياري';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ.';

  @override
  String get listSeparator => '، ';

  @override
  String get dotSeparator => ' · ';

  @override
  String get savedChanges => 'تم حفظ التعديلات.';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String percentValue(int value) {
    return '$value %';
  }

  @override
  String timeRange(String start, String end) {
    return '$start إلى $end';
  }

  @override
  String untilTime(String time) {
    return 'حتى $time';
  }

  @override
  String inDuration(String duration) {
    return 'بعد $duration';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationHours(int hours) {
    return '$hours س';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String todayDate(String date) {
    return 'اليوم، $date';
  }

  @override
  String tomorrowDate(String date) {
    return 'غدًا، $date';
  }

  @override
  String everyWeekday(String weekday) {
    return 'كل $weekday';
  }

  @override
  String get statusPlanned => 'مبرمجة';

  @override
  String get statusInProgress => 'جارية';

  @override
  String get statusDone => 'انتهت';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get statusNext => 'القادمة';

  @override
  String get modeInPerson => 'حضوري';

  @override
  String get modeOnline => 'عن بعد';

  @override
  String get attendancePresent => 'حاضر';

  @override
  String get attendanceAbsent => 'غائب';

  @override
  String get attendanceLate => 'متأخر';

  @override
  String presentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حاضر',
      many: '$count حاضرًا',
      few: '$count حاضرين',
      two: 'حاضران',
      one: 'حاضر واحد',
      zero: 'لا حاضرين',
    );
    return '$_temp0';
  }

  @override
  String absentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غائب',
      many: '$count غائبًا',
      few: '$count غائبين',
      two: 'غائبان',
      one: 'غائب واحد',
      zero: 'لا غائبين',
    );
    return '$_temp0';
  }

  @override
  String lateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متأخر',
      many: '$count متأخرًا',
      few: '$count متأخرين',
      two: 'متأخران',
      one: 'متأخر واحد',
      zero: 'لا متأخرين',
    );
    return '$_temp0';
  }

  @override
  String absencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غياب',
      many: '$count غيابًا',
      few: '$count غيابات',
      two: 'غيابان',
      one: 'غياب واحد',
      zero: 'لا غيابات',
    );
    return '$_temp0';
  }

  @override
  String studentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تلميذ',
      many: '$count تلميذًا',
      few: '$count تلاميذ',
      two: 'تلميذان',
      one: 'تلميذ واحد',
      zero: 'لا تلاميذ',
    );
    return '$_temp0';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: 'لا مجموعات',
    );
    return '$_temp0';
  }

  @override
  String privateLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس خصوصي',
      many: '$count درسًا خصوصيًا',
      few: '$count دروس خصوصية',
      two: 'درسان خصوصيان',
      one: 'درس خصوصي واحد',
      zero: 'لا دروس خصوصية',
    );
    return '$_temp0';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      many: '$count حصة',
      few: '$count حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
      zero: 'لا حصص',
    );
    return '$_temp0';
  }

  @override
  String get tabGroups => 'المجموعات';

  @override
  String get tabPrivateLessons => 'الدروس الخصوصية';

  @override
  String get tabArchived => 'المؤرشفون';

  @override
  String studentsYearSummary(String students, String groups, String lessons) {
    return '$students و$groups و$lessons هذه السنة.';
  }

  @override
  String get newStudent => 'تلميذ جديد';

  @override
  String get newGroup => 'مجموعة جديدة';

  @override
  String get searchStudents => 'الاسم أو المعرّف أو الهاتف';

  @override
  String get levelAll => 'المستوى: الكل';

  @override
  String levelFilter(String level) {
    return 'المستوى: $level';
  }

  @override
  String get columnStudent => 'التلميذ';

  @override
  String get columnGroups => 'المجموعات';

  @override
  String get columnParent => 'الولي';

  @override
  String get columnAttendance => 'الحضور';

  @override
  String get noParent => 'لا يوجد ولي';

  @override
  String get noGroup => 'بلا مجموعة';

  @override
  String get emptyStudents => 'لا يوجد تلاميذ حاليًا. أضف أول تلميذ.';

  @override
  String get emptyArchived => 'لا يوجد تلاميذ مؤرشفون.';

  @override
  String get emptyGroups => 'لا توجد مجموعات حاليًا. أنشئ أول مجموعة.';

  @override
  String get emptyPrivateLessons =>
      'لا توجد دروس خصوصية. أنشئ درسًا من بطاقة التلميذ.';

  @override
  String get restore => 'استرجاع';

  @override
  String get noSchedule => 'لا يوجد توقيت ثابت';

  @override
  String get addStudentsHint => 'أضف تلاميذ';

  @override
  String get privateLesson => 'درس خصوصي';

  @override
  String get studentFormSubtitle => 'تظهر معرّفاته بعد الحفظ.';

  @override
  String get editStudent => 'تعديل التلميذ';

  @override
  String get firstName => 'الاسم';

  @override
  String get lastName => 'اللقب';

  @override
  String get level => 'المستوى';

  @override
  String get chooseLevel => 'اختر المستوى';

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneHint => '8 أرقام';

  @override
  String get phoneInvalid => 'يجب أن يتكوّن الرقم من 8 أرقام.';

  @override
  String get username => 'المعرّف';

  @override
  String get usernameHint => 'يُنشأ من الاسم واللقب. يمكنك تغييره.';

  @override
  String get usernameAvailable => 'متاح';

  @override
  String get usernameTaken => 'مستعمل';

  @override
  String get groups => 'المجموعات';

  @override
  String get addGroup => 'إضافة مجموعة';

  @override
  String get parents => 'الأولياء';

  @override
  String parentsCount(int count) {
    return '$count من 2';
  }

  @override
  String get existingParent => 'ولي موجود';

  @override
  String get newParent => 'ولي جديد';

  @override
  String get relation => 'الصلة';

  @override
  String get relationMother => 'الأم';

  @override
  String get relationFather => 'الأب';

  @override
  String get relationGuardian => 'الوصي';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get newAccount => 'حساب جديد';

  @override
  String get searchParent => 'ابحث عن ولي';

  @override
  String parentOf(String children) {
    return 'وليّ $children';
  }

  @override
  String get noParentsYet => 'لا يوجد أولياء مسجّلون حاليًا.';

  @override
  String get parentLinked => 'مرتبط';

  @override
  String get credentialsTitle => 'تم إنشاء المعرّفات';

  @override
  String get credentialsSubtitle =>
      'أرسلها الآن: لن تظهر كلمات المرور مرة أخرى.';

  @override
  String get resetPasswordTitle => 'كلمة مرور مؤقتة جديدة';

  @override
  String get credentialUsername => 'المعرّف';

  @override
  String get credentialPassword => 'كلمة المرور المؤقتة';

  @override
  String get copyMessage => 'نسخ الرسالة';

  @override
  String get credentialsNote =>
      'سيختار كلّ واحد كلمة مروره عند أول دخول. في حال النسيان: بطاقة التلميذ، إعادة تعيين كلمة المرور.';

  @override
  String get credentialsDone => 'أرسلت المعرّفات';

  @override
  String get parentLoginNote => 'يسجّل الدخول برقم هاتفه';

  @override
  String credentialsMessage(
    String name,
    String app,
    String username,
    String password,
  ) {
    return 'مرحبًا $name، هذه معطيات دخولك إلى $app.\nالمعرّف: $username\nكلمة المرور المؤقتة: $password\nستختار كلمة مرورك الخاصة عند أول دخول.';
  }

  @override
  String get active => 'نشط';

  @override
  String get archivedStatus => 'مؤرشف';

  @override
  String usernameInline(String username) {
    return 'المعرّف $username';
  }

  @override
  String lastLogin(String when) {
    return 'آخر دخول $when';
  }

  @override
  String get neverLoggedIn => 'لم يسجّل الدخول بعد';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get archive => 'أرشفة';

  @override
  String archiveStudentTitle(String name) {
    return 'أرشفة $name؟';
  }

  @override
  String get archiveStudentText =>
      'لن يتمكّن من الدخول وسيختفي من القوائم. لا يُحذف أي شيء: يمكنك استرجاعه.';

  @override
  String studentArchived(String name) {
    return 'تمت أرشفة $name.';
  }

  @override
  String studentRestored(String name) {
    return 'تم استرجاع $name.';
  }

  @override
  String resetPasswordConfirm(String name) {
    return 'سيختار $name كلمة مرور جديدة. سيتم قطع الاتصال على أجهزته.';
  }

  @override
  String get statAttendance => 'الحضور هذه السنة';

  @override
  String get statLate => 'التأخيرات';

  @override
  String get statSessions => 'الحصص المحسوبة';

  @override
  String get sinceSeptember => 'منذ سبتمبر';

  @override
  String get nextSessions => 'الحصص القادمة';

  @override
  String get noUpcoming => 'لا توجد حصص مبرمجة.';

  @override
  String get attendanceTitle => 'الحضور';

  @override
  String get lastTenSessions => 'آخر 10 حصص';

  @override
  String get noAttendanceYet => 'لم يُسجَّل أي حضور بعد.';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get commentsVisibility => 'يراه التلميذ وأولياؤه';

  @override
  String get commentHint => 'كلمة للتلميذ وأوليائه…';

  @override
  String get privateNotesTitle => 'ملاحظات خاصة';

  @override
  String get privateNotesVisibility => 'تراها أنت فقط';

  @override
  String get noPrivateNotes => 'لا توجد ملاحظات خاصة.';

  @override
  String get noteHint => 'اكتب ملاحظتك…';

  @override
  String get deleteNoteTitle => 'حذف هذه الملاحظة؟';

  @override
  String get createPrivateLesson => 'إنشاء درس خصوصي';

  @override
  String privateLessonText(String name) {
    return 'مجموعة لـ$name وحده، في المادة المختارة.';
  }

  @override
  String get privateLessonCreated => 'تم إنشاء الدرس الخصوصي.';

  @override
  String get subject => 'المادة';

  @override
  String get chooseSubject => 'اختر المادة';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'مثال: السنة الرابعة · رياضيات';

  @override
  String get groupFormSubtitle => 'ستضيف التلاميذ والتوقيت بعد ذلك.';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get color => 'اللون';

  @override
  String get defaultMeetLink => 'رابط Meet الافتراضي';

  @override
  String get meetLinkHint => 'https://meet.google.com/…';

  @override
  String get meetLinkInvalid => 'يجب أن يبدأ الرابط بـ https://';

  @override
  String get addMembers => 'إضافة تلاميذ';

  @override
  String get groupMembersTitle => 'تلاميذ المجموعة';

  @override
  String get usualSchedule => 'التوقيت المعتاد';

  @override
  String scheduleNote(String date) {
    return 'الحصص مبرمجة حتى $date. تُعدَّل الحصة وحدها أو مع الحصص التالية.';
  }

  @override
  String get noScheduleYet =>
      'لا يوجد توقيت معتاد. برمج حصة وفعّل التكرار الأسبوعي.';

  @override
  String get noMeetLink => 'لا يوجد رابط. الحصص حضورية.';

  @override
  String get archiveGroup => 'أرشفة المجموعة';

  @override
  String get archiveGroupText =>
      'تختفي المجموعة من القوائم. تبقى حصصها الماضية في سجلّ التلاميذ.';

  @override
  String get groupArchived => 'تمت أرشفة المجموعة.';

  @override
  String get noMembers => 'لا يوجد تلاميذ في هذه المجموعة.';

  @override
  String get chooseStudents => 'اختيار التلاميذ';

  @override
  String selectedCount(int count) {
    return '$count مختارين';
  }

  @override
  String get saveMembers => 'حفظ';

  @override
  String get viewDay => 'يوم';

  @override
  String get viewWeek => 'أسبوع';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get allGroups => 'كل المجموعات';

  @override
  String get newSession => 'حصة جديدة';

  @override
  String get planningLegend =>
      'باهتة: انتهت · مشطوبة: ملغاة · انقر على خانة فارغة لإضافة حصة';

  @override
  String get emptyWeek => 'لا توجد حصص هذا الأسبوع.';

  @override
  String get emptyDay => 'لا توجد حصص في هذا اليوم.';

  @override
  String get editSession => 'تعديل الحصة';

  @override
  String get group => 'المجموعة';

  @override
  String get chooseGroup => 'اختر مجموعة';

  @override
  String get date => 'التاريخ';

  @override
  String get startTime => 'البداية';

  @override
  String get endTime => 'النهاية';

  @override
  String get mode => 'الطريقة';

  @override
  String get location => 'المكان';

  @override
  String get locationHint => 'مثال: القاعة 2';

  @override
  String get meetLink => 'رابط الحصة عن بعد';

  @override
  String get fromGroup => 'من المجموعة';

  @override
  String get repeatWeekly => 'تكرار كل أسبوع';

  @override
  String repeatWeeklyHint(String weekday, String date) {
    return 'كل $weekday حتى $date';
  }

  @override
  String get repeatUntil => 'حتى';

  @override
  String get sessionsToCreate => 'الحصص المبرمجة';

  @override
  String createSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إنشاء $count حصة',
      many: 'إنشاء $count حصة',
      few: 'إنشاء $count حصص',
      two: 'إنشاء حصتين',
      one: 'إنشاء الحصة',
      zero: 'إنشاء',
    );
    return '$_temp0';
  }

  @override
  String overlapWarning(String session) {
    return 'تتداخل مع حصة: $session. يمكنك المواصلة.';
  }

  @override
  String get prepNotes => 'ملاحظات التحضير';

  @override
  String get prepNotesHint => 'ما تريد مراجعته…';

  @override
  String get timeRangeInvalid => 'يجب أن تكون ساعة النهاية بعد ساعة البداية.';

  @override
  String get noGroupsYet => 'أنشئ مجموعة أولًا في قسم التلاميذ.';

  @override
  String sessionsCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إنشاء $count حصة.',
      many: 'تم إنشاء $count حصة.',
      few: 'تم إنشاء $count حصص.',
      two: 'تم إنشاء حصتين.',
      one: 'تم إنشاء الحصة.',
      zero: 'لم تُنشأ أي حصة.',
    );
    return '$_temp0';
  }

  @override
  String get sessionUpdated => 'تم تعديل الحصة.';

  @override
  String get startSession => 'بدء الحصة';

  @override
  String get resumeSession => 'استئناف الحصة';

  @override
  String get openMeet => 'فتح Meet';

  @override
  String everyWeekdayUntil(String weekday, String date) {
    return 'كل $weekday، حتى $date';
  }

  @override
  String get cancelSession => 'إلغاء الحصة';

  @override
  String get restoreSession => 'إعادة برمجة الحصة';

  @override
  String cancelledBecause(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get seriesNote => 'هذه الحصة جزء من سلسلة.';

  @override
  String get scopeOne => 'هذه الحصة فقط';

  @override
  String get scopeFollowing => 'هذه الحصة والحصص التالية';

  @override
  String scopeFollowingCount(String count, String date) {
    return '$count حتى $date';
  }

  @override
  String get cancelReason => 'السبب';

  @override
  String get cancelReasonVisibility => 'يظهر للتلميذ وأوليائه';

  @override
  String get cancelReasonHint => 'مثال: امتحان في المعهد';

  @override
  String get cancelVisibleNote =>
      'يتم إعلام التلاميذ وأوليائهم في التطبيق ويرون السبب في جدولهم.';

  @override
  String get sessionCancelled => 'تم إلغاء الحصة.';

  @override
  String get sessionRestored => 'تمت إعادة برمجة الحصة.';

  @override
  String get editAttendance => 'تعديل الحضور';

  @override
  String inProgressFor(int minutes) {
    return 'جارية · $minutes د';
  }

  @override
  String get endSession => 'إنهاء الحصة';

  @override
  String get tapToChange => 'المس اسم التلميذ للتغيير';

  @override
  String get contentOfDay => 'محتوى اليوم';

  @override
  String lastSessionOn(String day) {
    return 'آخر حصة · $day';
  }

  @override
  String get noPreviousNote => 'لا توجد ملاحظة عن الحصة الأخيرة.';

  @override
  String get quickNote => 'ملاحظة سريعة';

  @override
  String get quickNoteHint => 'ما حدث وما يجب مراجعته في المرة القادمة…';

  @override
  String get noteSaved => 'تم الحفظ';

  @override
  String get noteSaving => 'جارٍ الحفظ…';

  @override
  String get endSessionTitle => 'إنهاء الحصة؟';

  @override
  String endSessionText(String summary) {
    return 'الحضور المسجَّل: $summary.';
  }

  @override
  String get sessionEnded => 'انتهت الحصة.';

  @override
  String get joinSession => 'الانضمام إلى الحصة';

  @override
  String childSessions(String name) {
    return 'حصص $name';
  }

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String cancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة ملغاة',
      many: '$count حصة ملغاة',
      few: '$count حصص ملغاة',
      two: 'حصتان ملغاتان',
      one: 'حصة ملغاة',
      zero: 'لا إلغاءات',
    );
    return '$_temp0';
  }

  @override
  String absencesThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غياب هذا الشهر',
      many: '$count غيابًا هذا الشهر',
      few: '$count غيابات هذا الشهر',
      two: 'غيابان هذا الشهر',
      one: 'غياب واحد هذا الشهر',
      zero: 'لا غيابات هذا الشهر',
    );
    return '$_temp0';
  }

  @override
  String get emptyMyPlanning => 'لا توجد حصص في الأسبوعين القادمين.';

  @override
  String todayInDuration(String duration) {
    return 'اليوم، بعد $duration';
  }

  @override
  String homeSessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة اليوم.',
      many: '$count حصة اليوم.',
      few: '$count حصص اليوم.',
      two: 'حصتان اليوم.',
      one: 'حصة واحدة اليوم.',
      zero: 'لا توجد حصص اليوم.',
    );
    return '$_temp0';
  }

  @override
  String tomorrowSessions(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'غدًا: $count حصة، الأولى على الساعة $time.',
      many: 'غدًا: $count حصة، الأولى على الساعة $time.',
      few: 'غدًا: $count حصص، الأولى على الساعة $time.',
      two: 'غدًا: حصتان، الأولى على الساعة $time.',
      one: 'غدًا: حصة واحدة على الساعة $time.',
      zero: 'غدًا: لا توجد حصص.',
    );
    return '$_temp0';
  }

  @override
  String attendanceOf(int present, int total) {
    return 'الحضور $present من $total';
  }

  @override
  String get childAccess => 'حساب دخول التلميذ';

  @override
  String get childAccessHint =>
      'اختياري. لا يحتاجه غالبًا تلاميذ الابتدائي: يتابع الأولياء كل شيء.';

  @override
  String get createChildAccess => 'إنشاء حساب دخول';

  @override
  String get removeChildAccess => 'سحب حساب الدخول';

  @override
  String removeChildAccessText(String name) {
    return 'لن يتمكّن $name من الدخول. يواصل أولياؤه متابعة كل شيء.';
  }

  @override
  String get childAccessRemoved => 'تم سحب حساب الدخول.';

  @override
  String get noChildAccess => 'دون حساب، يتابعه أولياؤه';

  @override
  String get newSubject => 'مادة جديدة';

  @override
  String get subjectNameFr => 'الاسم بالفرنسية';

  @override
  String get subjectNameAr => 'الاسم بالعربية';

  @override
  String get subjectNameHint => 'مثال: الرياضيات، القراءة، الإيقاظ العلمي';

  @override
  String get subjectNameArHint => 'إذا تُرك فارغًا يظهر الاسم الفرنسي.';

  @override
  String get subjectCreated => 'تم إنشاء المادة.';

  @override
  String get settingsSubtitle =>
      'المواد التي تدرّسها ومستوياتك والسنة الدراسية.';

  @override
  String get yourSubjects => 'موادك';

  @override
  String get subjectNoArabicName => 'لا يوجد اسم عربي: يُعرض الاسم الفرنسي';

  @override
  String get subjectInUse => 'تستعملها مجموعة: لا يمكن حذفها.';

  @override
  String get subjectDeleteRule =>
      'لا يمكن حذف مادة تستعملها مجموعة: غيّر مادة المجموعة أولًا.';

  @override
  String get editSubject => 'تعديل المادة';

  @override
  String get subjectUpdated => 'تم تعديل المادة.';

  @override
  String deleteSubjectTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deleteSubjectText => 'لا تستعملها أي مجموعة. هذا الحذف نهائي.';

  @override
  String get subjectDeleted => 'تم حذف المادة.';

  @override
  String get levelsTitle => 'المستويات';

  @override
  String get primarySchool => 'ابتدائي';

  @override
  String get levelsNote =>
      'السنوات الست من التعليم الابتدائي التونسي، بالفرنسية والعربية.';

  @override
  String get schoolYearTitle => 'السنة الدراسية';

  @override
  String schoolYearRange(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String get noSubjectsYet => 'لا توجد مواد حاليًا. أنشئ أول مادة.';

  @override
  String get loginIdentifierHint => 'المعرّف أو الرقم';

  @override
  String get loginPasswordHint => 'كلمة المرور';

  @override
  String notificationsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إشعار غير مقروء',
      many: '$count إشعارًا غير مقروء',
      few: '$count إشعارات غير مقروءة',
      two: 'إشعاران غير مقروءين',
      one: 'إشعار واحد غير مقروء',
      zero: 'كل شيء مقروء',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsEarlier => 'قبل ذلك';

  @override
  String notificationCancelled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ألغيت $count حصة',
      many: 'ألغيت $count حصة',
      few: 'ألغيت $count حصص',
      two: 'ألغيت حصتان',
      one: 'ألغيت الحصة',
      zero: 'لا حصص ملغاة',
    );
    return '$_temp0';
  }

  @override
  String notificationMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تغيّر موعد $count حصة',
      many: 'تغيّر موعد $count حصة',
      few: 'تغيّر موعد $count حصص',
      two: 'تغيّر موعد حصتين',
      one: 'تغيّر موعد الحصة',
      zero: 'لا حصص تغيّر موعدها',
    );
    return '$_temp0';
  }

  @override
  String get notificationRestored => 'أعيدت برمجة الحصة';

  @override
  String fromDate(String date) {
    return 'ابتداءً من $date';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'أمس';

  @override
  String get noNotifications => 'لا توجد إشعارات حاليًا.';

  @override
  String get noNotificationsHint =>
      'ستصلك هنا رسالة إذا أُلغيت حصة أو تغيّر موعدها أو أعيدت برمجتها.';

  @override
  String get familiesWillBeTold =>
      'إذا تغيّر التاريخ أو الوقت، سيتم إعلام التلاميذ والأولياء في التطبيق.';

  @override
  String get modeInClass => 'في القسم';

  @override
  String weekSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقيت لك $count حصة هذا الأسبوع.',
      many: 'بقيت لك $count حصة هذا الأسبوع.',
      few: 'بقيت لك $count حصص هذا الأسبوع.',
      two: 'بقيت لك حصتان هذا الأسبوع.',
      one: 'بقيت لك حصة واحدة هذا الأسبوع.',
      zero: 'لا حصص أخرى هذا الأسبوع.',
    );
    return '$_temp0';
  }

  @override
  String get whatsNew => 'جديد';

  @override
  String get myWeek => 'أسبوعي';

  @override
  String get seePlanning => 'عرض الجدول';

  @override
  String get legendSession => 'حصة';

  @override
  String nextWeekSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الأسبوع القادم: $count حصة.',
      many: 'الأسبوع القادم: $count حصة.',
      few: 'الأسبوع القادم: $count حصص.',
      two: 'الأسبوع القادم: حصتان.',
      one: 'الأسبوع القادم: حصة واحدة.',
      zero: 'لا حصص الأسبوع القادم.',
    );
    return '$_temp0';
  }

  @override
  String get nextWeek => 'الأسبوع القادم';

  @override
  String get laterOn => 'لاحقًا';

  @override
  String tomorrowWeekday(String weekday) {
    return 'غدًا، $weekday';
  }

  @override
  String get newTime => 'موعد جديد';

  @override
  String previousTime(String when) {
    return 'قبل: $when';
  }

  @override
  String dayAtTime(String day, String time) {
    return '$day على الساعة $time';
  }

  @override
  String get joinOpensBefore => 'يظهر رابط الانضمام قبل 15 دقيقة.';

  @override
  String get noNotificationsHintStudent =>
      'ستصلك هنا رسالة إذا أُلغيت حصة أو تغيّر موعدها أو أعيدت برمجتها.';

  @override
  String get roleAdmin => 'المشرف';

  @override
  String get navTeachers => 'المعلّمون';

  @override
  String get adminArea => 'الإدارة';

  @override
  String get teachersSubtitle =>
      'يعمل كلّ معلّم في فضائه الخاص، مع تلاميذه وأوليائهم.';

  @override
  String get newTeacher => 'معلّم جديد';

  @override
  String teachersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معلّم',
      many: '$count معلّمًا',
      few: '$count معلّمين',
      two: 'معلّمان',
      one: 'معلّم واحد',
      zero: 'لا معلّمين',
    );
    return '$_temp0';
  }

  @override
  String activeAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب نشط',
      many: '$count حسابًا نشطًا',
      few: '$count حسابات نشطة',
      two: 'حسابان نشطان',
      one: 'حساب نشط واحد',
      zero: 'لا حساب نشط',
    );
    return '$_temp0';
  }

  @override
  String get statStudents => 'التلاميذ المتابَعون';

  @override
  String get statParents => 'حسابات الأولياء';

  @override
  String get statGroups => 'المجموعات الجارية';

  @override
  String get allSpaces => 'كل الفضاءات';

  @override
  String get searchTeachers => 'الاسم أو المعرّف أو الهاتف';

  @override
  String get columnTeacher => 'المعلّم';

  @override
  String get columnStatus => 'الحالة';

  @override
  String get columnStudents => 'التلاميذ';

  @override
  String get columnLastLogin => 'آخر دخول';

  @override
  String get teacherActive => 'نشط';

  @override
  String get teacherTemporaryPassword => 'كلمة مرور مؤقتة';

  @override
  String get teacherDisabled => 'معطّل';

  @override
  String get lastLoginNever => 'لم يدخل بعد';

  @override
  String get teacherActions => 'إجراءات';

  @override
  String get disableAccess => 'تعطيل الدخول';

  @override
  String get enableAccess => 'إعادة تفعيل الدخول';

  @override
  String disableTeacherTitle(String name) {
    return 'تعطيل دخول $name؟';
  }

  @override
  String get disableTeacherText =>
      'سيُمنع الدخول إلى هذا الحساب. يحتفظ تلاميذه وأولياؤهم بدخولهم. لا يُحذف أي شيء ويمكنك إعادة تفعيله.';

  @override
  String teacherDisabledNotice(String name) {
    return 'تم تعطيل دخول $name.';
  }

  @override
  String teacherEnabledNotice(String name) {
    return 'تمت إعادة تفعيل دخول $name.';
  }

  @override
  String get newTeacherSubtitle => 'يُنشأ معرّف وكلمة مرور مؤقتة لأوّل دخول.';

  @override
  String get teacherUsernameHint => 'للدخول. يصلح الهاتف أيضًا إن أُدخل.';

  @override
  String get usernameRule =>
      '3 أحرف على الأقل: حروف لاتينية دون نبرة، أرقام، نقطة، شرطة.';

  @override
  String get createTeacherAccount => 'إنشاء الحساب';

  @override
  String get noTeachers => 'لا يوجد معلّمون حاليًا.';

  @override
  String get noTeachersHint => 'أضف الأوّل: يحصل على معرّف وكلمة مرور مؤقتة.';

  @override
  String get teacherCredentialsNote =>
      'لا تظهر كلمة المرور المؤقتة إلا مرة واحدة. يختار المعلّم كلمة مروره عند أوّل دخول. في حال النسيان: إجراءات، إعادة تعيين كلمة المرور.';

  @override
  String get studentFirstNameHint => 'مثال: آدم';

  @override
  String get parentFirstNameHint => 'مثال: منى';

  @override
  String get teacherFirstNameHint => 'مثال: سنية';

  @override
  String get lastNameHint => 'مثال: الغربي';

  @override
  String get teacherLastNameHint => 'مثال: بن علي';

  @override
  String get studentUsernameExample => 'adam.gharbi';

  @override
  String get teacherUsernameExample => 'sonia.benali';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get subjectNameArExample => 'مثال: الرياضيات';

  @override
  String get relationHint => 'الأم، الأب، الوصي';

  @override
  String get temporaryPasswordHint => 'كلمة المرور التي وصلتك';

  @override
  String get currentPasswordHint => 'التي تستعملها للدخول';

  @override
  String get newPasswordHint => 'سهلة التذكّر، صعبة التخمين';

  @override
  String get confirmPasswordHint => 'نفسها مرة ثانية';

  @override
  String get contentsSubtitle => 'وثائقك مرتّبة حسب المادة والمستوى والفصل.';

  @override
  String get newChapter => 'فصل جديد';

  @override
  String get importDocument => 'استيراد وثيقة';

  @override
  String get importShort => 'استيراد';

  @override
  String get shareChapter => 'مشاركة الفصل';

  @override
  String get unfiled => 'بدون فصل';

  @override
  String get searchTitle => 'ابحث عن عنوان';

  @override
  String get tagAll => 'التصنيف: الكل';

  @override
  String tagFilter(String tag) {
    return 'التصنيف: $tag';
  }

  @override
  String get statusAll => 'الحالة: الكل';

  @override
  String statusFilter(String status) {
    return 'الحالة: $status';
  }

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وثيقة',
      many: '$count وثيقة',
      few: '$count وثائق',
      two: 'وثيقتان',
      one: 'وثيقة واحدة',
      zero: 'لا وثائق',
    );
    return '$_temp0';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      many: '$count صفحة',
      few: '$count صفحات',
      two: 'صفحتان',
      one: 'صفحة واحدة',
      zero: 'لا صفحات',
    );
    return '$_temp0';
  }

  @override
  String get columnDocument => 'الوثيقة';

  @override
  String get columnTag => 'التصنيف';

  @override
  String get columnSharedWith => 'مشارَك مع';

  @override
  String get columnEdited => 'آخر تعديل';

  @override
  String get notShared => 'غير مشارَك';

  @override
  String get tagSerie => 'سلسلة';

  @override
  String get tagCours => 'درس';

  @override
  String get tagCorrige => 'إصلاح';

  @override
  String get tagAutre => 'أخرى';

  @override
  String get statusPublished => 'منشور';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get kindPdf => 'PDF';

  @override
  String get kindImage => 'صورة';

  @override
  String get kindWord => 'Word';

  @override
  String get toDownload => 'للتنزيل';

  @override
  String sizeKb(String value) {
    return '$value ك.ب';
  }

  @override
  String sizeMb(String value) {
    return '$value م.ب';
  }

  @override
  String get actionOpen => 'فتح';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionEditDetails => 'تعديل التفاصيل';

  @override
  String get renameChapter => 'إعادة تسمية الفصل';

  @override
  String get deleteChapter => 'حذف الفصل';

  @override
  String get documentActions => 'إجراءات الوثيقة';

  @override
  String get chapterActions => 'إجراءات الفصل';

  @override
  String archiveDocumentTitle(String title) {
    return 'أرشفة «$title»؟';
  }

  @override
  String get archiveDocumentText =>
      'تختفي من المكتبة ومن تبويبات الدروس. لا يُحذف أي شيء.';

  @override
  String deleteChapterTitle(String title) {
    return 'حذف الفصل «$title»؟';
  }

  @override
  String get deleteChapterText =>
      'تبقى وثائقه في «بدون فصل». تتوقّف مشاركة الفصل.';

  @override
  String get documentArchived => 'تمّت أرشفة الوثيقة.';

  @override
  String get chapterDeleted => 'تمّ حذف الفصل.';

  @override
  String get documentUploaded => 'تمّ استيراد الوثيقة.';

  @override
  String get detailsSaved => 'تمّ حفظ التعديلات.';

  @override
  String get shareSaved => 'تمّ حفظ المشاركة.';

  @override
  String get libraryEmptyTitle => 'مكتبتك فارغة.';

  @override
  String get libraryEmptyHint =>
      'استورد سلسلة أو درسًا أو صورة للسبورة، ثم شاركها مع مجموعة.';

  @override
  String get chapterEmpty => 'لا توجد وثائق في هذا الفصل.';

  @override
  String get subjectEmpty => 'لا توجد وثائق في هذه المادة حاليًا.';

  @override
  String get draftCannotShare => 'لا يمكن مشاركة مسودة. انشرها أولًا.';

  @override
  String get importSubtitle =>
      'قسم كامل دفعة واحدة من Excel: التلاميذ وأولياؤهم وحساباتهم.';

  @override
  String get editDetailsSubtitle => 'العنوان والترتيب والتصنيف والحالة.';

  @override
  String get chooseFile => 'اختيار ملف';

  @override
  String get changeFile => 'تغيير';

  @override
  String get fileUnsupported =>
      'صيغة غير مقبولة: اختر ملف PDF أو صورة JPG أو PNG أو ملف Word.';

  @override
  String get fileTooLarge => 'يتجاوز هذا الملف 20 م.ب.';

  @override
  String get fileEmpty => 'هذا الملف فارغ.';

  @override
  String get fileRequired => 'اختر ملفًا.';

  @override
  String get documentTitle => 'العنوان';

  @override
  String get documentTitleHint => 'مثال: السلسلة 2: الكسور';

  @override
  String get documentTitleHelper => 'يرى التلاميذ هذا العنوان.';

  @override
  String get chapter => 'الفصل';

  @override
  String get tag => 'التصنيف';

  @override
  String get shareWith => 'مشاركة مع';

  @override
  String get shareWithHint =>
      'يراها تلاميذ هذه المجموعات في الدروس. يمكنك المشاركة لاحقًا.';

  @override
  String get keepDraft => 'الإبقاء كمسودة';

  @override
  String get keepDraftHint => 'لا يرى التلاميذ المسودة أبدًا.';

  @override
  String uploadProgress(int percent) {
    return 'الإرسال: $percent %';
  }

  @override
  String get chapterTitle => 'عنوان الفصل';

  @override
  String get chapterTitleHint => 'مثال: الكسور';

  @override
  String shareDocumentTitle(String title) {
    return 'مشاركة «$title»';
  }

  @override
  String shareChapterTitle(String title) {
    return 'مشاركة الفصل «$title»';
  }

  @override
  String get shareSubtitle =>
      'يراها تلاميذ المجموعات المختارة في تبويب الدروس.';

  @override
  String get shareChapterSubtitle => 'كل وثائقه المنشورة، والتي تُضاف لاحقًا.';

  @override
  String groupsOfLevel(String level) {
    return 'مجموعات $level';
  }

  @override
  String get otherGroups => 'مجموعات أخرى';

  @override
  String get unshareNote =>
      'إلغاء اختيار مجموعة يزيل الوثيقة من تبويب الدروس. لا يُحذف أي شيء.';

  @override
  String get download => 'تنزيل';

  @override
  String pageOf(int page, int count) {
    return 'صفحة $page من $count';
  }

  @override
  String get previousPage => 'الصفحة السابقة';

  @override
  String get nextPage => 'الصفحة التالية';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get details => 'التفاصيل';

  @override
  String get detailFile => 'الملف';

  @override
  String get wordNoPreview => 'لا يُفتح ملف Word داخل التطبيق. نزّله لقراءته.';

  @override
  String get downloadFailed => 'تعذّر بدء التنزيل.';

  @override
  String get pageNotShown => 'تعذّر عرض هذه الصفحة.';

  @override
  String get myCoursesTitle => 'دروسي';

  @override
  String get myCoursesSubtitle => 'ما تمّت مشاركته معك، حسب المادة.';

  @override
  String parentCoursesTitle(String name) {
    return 'دروس $name';
  }

  @override
  String parentCoursesSubtitle(String name) {
    return 'الوثائق المشارَكة مع $name. يمكنك فتحها وطباعتها.';
  }

  @override
  String get allSubjects => 'الكل';

  @override
  String get newBadge => 'جديد';

  @override
  String get coursEmpty => 'لم تتمّ مشاركة أي شيء معك بعد.';

  @override
  String coursEmptyParent(String name) {
    return 'لم تتمّ مشاركة أي شيء مع $name بعد.';
  }

  @override
  String get scanSheets => 'مسح الأوراق';

  @override
  String get scanSheetsHint => 'عدة صفحات في ملف PDF واحد';

  @override
  String get fileTypesShort => 'PDF، JPG، PNG، Word';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get fromGallery => 'من المعرض';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get scanHint =>
      'ضع الورقة مسطّحة وفي إضاءة جيدة. اضغط على صفحة لقصّها أو تدويرها، واضغط مطوّلًا لتحريكها.';

  @override
  String get scanColor => 'بالألوان';

  @override
  String get scanBlackWhite => 'بالأبيض والأسود';

  @override
  String get createPdf => 'إنشاء ملف PDF';

  @override
  String get scanEmptyTitle => 'التقط صورة للورقة الأولى.';

  @override
  String get scanEmptyHint =>
      'صورة لكل ورقة. يمكنك القصّ والتدوير وتغيير الترتيب.';

  @override
  String get scanPreparing => 'جارٍ التحضير…';

  @override
  String get scanDiscardTitle => 'التخلّي عن المسح؟';

  @override
  String get scanDiscardText => 'ستضيع الصور الملتقطة هنا.';

  @override
  String get scanDiscard => 'التخلّي';

  @override
  String get rotate => 'تدوير';

  @override
  String get resetCrop => 'استرجاع';

  @override
  String get validate => 'تأكيد';

  @override
  String get deletePage => 'حذف الصفحة';

  @override
  String get cropHint => 'اسحب الزوايا إلى حواف الورقة.';

  @override
  String scanFileName(String date) {
    return 'مسح $date';
  }

  @override
  String get scanPhotoFailed => 'تعذّرت قراءة إحدى الصور.';

  @override
  String get scanPdfFailed => 'تعذّر إنشاء ملف PDF.';

  @override
  String pageNumber(int number) {
    return 'صفحة $number';
  }

  @override
  String get cropCorner => 'زاوية الورقة';

  @override
  String get scanEmptyTitleComputer => 'أضف صور أوراقك.';

  @override
  String get scanEmptyHintComputer =>
      'اختر الصور الملتقطة مسبقًا، صورة لكل ورقة. يمكنك القصّ والتدوير وتغيير الترتيب.';

  @override
  String get homeworkSubtitle => 'ما على تلاميذك إنجازه، ومن أرسله.';

  @override
  String get newHomework => 'واجب جديد';

  @override
  String get homeworkOpen => 'جارية';

  @override
  String get homeworkDone => 'منتهية';

  @override
  String get groupAll => 'المجموعة: الكل';

  @override
  String groupFilter(String name) {
    return 'المجموعة: $name';
  }

  @override
  String get columnHomework => 'الواجب';

  @override
  String get columnDueFor => 'آخر أجل';

  @override
  String get columnSent => 'المُرسَل';

  @override
  String sentOf(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count من $total',
      many: '$count من $total',
      few: '$count من $total',
      two: 'اثنان من $total',
      one: 'واحد من $total',
      zero: 'لا شيء من $total',
    );
    return '$_temp0';
  }

  @override
  String missingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ناقص',
      many: '$count ناقصًا',
      few: '$count ناقصة',
      two: 'اثنان ناقصان',
      one: 'واحد ناقص',
      zero: 'لا شيء ناقص',
    );
    return '$_temp0';
  }

  @override
  String get nothingToSubmit => 'لا شيء للإرسال';

  @override
  String get toRead => 'للقراءة';

  @override
  String dueToday(String time) {
    return 'اليوم، $time';
  }

  @override
  String dueTomorrow(String time) {
    return 'غدًا، $time';
  }

  @override
  String dueOn(String date, String time) {
    return '$date، $time';
  }

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count يوم',
      many: 'بعد $count يومًا',
      few: 'بعد $count أيام',
      two: 'بعد يومين',
      one: 'غدًا',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يومًا',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'أمس',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String get homeworkInfo =>
      'بعد آخر أجل، يصبح الواجب غير المُرسل «لم يُرسل» تلقائيًا. يرى التلاميذ وأولياؤهم كل واجب جديد في إشعاراتهم.';

  @override
  String get homeworkEmpty => 'لا توجد واجبات جارية.';

  @override
  String get homeworkEmptyHint => 'أعطِ وثيقة من محتواك لمجموعة، مع آخر أجل.';

  @override
  String get homeworkDoneEmpty => 'لا توجد واجبات منتهية حاليًا.';

  @override
  String get newHomeworkSubtitle =>
      'وثيقة من المكتبة، لمجموعة أو لبعض التلاميذ، مع آخر أجل.';

  @override
  String get documentLabel => 'الوثيقة';

  @override
  String get chooseDocument => 'اختر وثيقة';

  @override
  String get noPublishedDocuments => 'استورد وثيقة أولًا في المحتوى.';

  @override
  String get homeworkTitleHelper =>
      'مأخوذ من الوثيقة. يرى التلاميذ هذا العنوان.';

  @override
  String get forLabel => 'لِـ';

  @override
  String get forGroup => 'مجموعة';

  @override
  String get forStudents => 'بعض التلاميذ';

  @override
  String get pickStudentsRequired => 'اختر تلميذًا واحدًا على الأقل.';

  @override
  String get deadlineDate => 'آخر أجل';

  @override
  String get deadlineTime => 'الساعة';

  @override
  String get deadlineInPast => 'اختر آخر أجل لم يحن بعد.';

  @override
  String get submissionLabel => 'الإرسال';

  @override
  String get modeFile => 'صور أو PDF';

  @override
  String get modeNone => 'لا شيء للإرسال';

  @override
  String get modeFileHint =>
      'يصوّر التلاميذ كرّاسهم: تصبح الصفحات ملف PDF واحدًا.';

  @override
  String get modeNoneHint => 'وثيقة للقراءة، دون حالة.';

  @override
  String get instructionsLabel => 'التعليمات';

  @override
  String get instructionsHint => 'مثال: أنجز التمارين من 1 إلى 3 في كرّاسك.';

  @override
  String get allowLate => 'قبول الإرسال المتأخّر';

  @override
  String get allowLateHint => 'يُعلَّم بـ«أُرسل متأخّرًا».';

  @override
  String get giveHomework => 'إعطاء الواجب';

  @override
  String get homeworkGiven => 'تمّ إعطاء الواجب.';

  @override
  String get giveAsHomework => 'إعطاء كواجب';

  @override
  String get hwStatusTodo => 'للإنجاز';

  @override
  String get hwStatusSubmitted => 'أُرسل';

  @override
  String get hwStatusLate => 'أُرسل متأخّرًا';

  @override
  String get hwStatusMissing => 'لم يُرسل';

  @override
  String get hwStatusCorrected => 'مُصحَّح';

  @override
  String get tileSubmitted => 'أُرسلت';

  @override
  String get tileLate => 'أُرسلت متأخّرة';

  @override
  String get tileMissing => 'لم تُرسل';

  @override
  String get tileTodo => 'للإنجاز';

  @override
  String get columnSentAt => 'أُرسل في';

  @override
  String get viewWork => 'عرض العمل';

  @override
  String get nothingReceived => 'لم يصل شيء';

  @override
  String get changeDeadline => 'تغيير آخر أجل';

  @override
  String get closeHomework => 'إغلاق';

  @override
  String closeHomeworkTitle(String title) {
    return 'إغلاق «$title»؟';
  }

  @override
  String get closeHomeworkText =>
      'لن يمكن إرسال أي عمل بعد الآن. يبقى ما أُرسل.';

  @override
  String get homeworkClosed => 'تمّ إغلاق الواجب.';

  @override
  String get deadlineChanged => 'تمّ تغيير آخر أجل.';

  @override
  String get lateAccepted => 'التأخير مقبول';

  @override
  String get closedChip => 'مغلق';

  @override
  String dueFor(String when) {
    return 'آخر أجل: $when';
  }

  @override
  String get newDeadline => 'آخر أجل جديد';

  @override
  String get myHomeworkTitle => 'واجباتي';

  @override
  String get myHomeworkSubtitle => 'ما عليك إنجازه، الأكثر استعجالًا أولًا.';

  @override
  String parentHomeworkTitle(String name) {
    return 'واجبات $name';
  }

  @override
  String parentHomeworkSubtitle(String name) {
    return 'ما على $name إنجازه وما أُرسل.';
  }

  @override
  String get sectionTodo => 'للإنجاز';

  @override
  String get sectionDone => 'المنتهية';

  @override
  String dueLabel(String when) {
    return 'آخر أجل: $when';
  }

  @override
  String sentOn(String when) {
    return 'أُرسل $when';
  }

  @override
  String readBefore(String when) {
    return 'للقراءة قبل $when';
  }

  @override
  String get myHomeworkEmpty => 'لا توجد واجبات حاليًا.';

  @override
  String parentHomeworkEmpty(String name) {
    return 'لا توجد واجبات لـ$name حاليًا.';
  }

  @override
  String get yourWork => 'عملك';

  @override
  String childWork(String name) {
    return 'عمل $name';
  }

  @override
  String get workPhotosHint => 'صورة لكل صفحة من الكرّاس: تصبح ملف PDF واحدًا.';

  @override
  String get takeMyWork => 'تصوير عملي';

  @override
  String get takeTheWork => 'تصوير العمل';

  @override
  String get orChooseFile => 'أو اختيار ملف';

  @override
  String get replaceMyWork => 'تعويض عملي';

  @override
  String get replaceTheWork => 'تعويض العمل';

  @override
  String get workSent => 'تمّ الإرسال!';

  @override
  String get myWork => 'عملي';

  @override
  String get sentWork => 'العمل المُرسَل';

  @override
  String canReplaceUntilTu(String when) {
    return 'يمكنك تعويضه حتى $when.';
  }

  @override
  String canReplaceUntil(String when) {
    return 'يمكنك تعويضه حتى $when.';
  }

  @override
  String get deadlinePassedNotice =>
      'انقضى آخر أجل: لم يعد ممكنًا إرسال الواجب.';

  @override
  String get closedNotice => 'هذا الواجب مغلق.';

  @override
  String get readOnlyNotice => 'لا شيء للإرسال: تكفي قراءة الوثيقة.';

  @override
  String get missingNotice => 'لم يُرسل شيء قبل آخر أجل.';

  @override
  String get lateSentNotice => 'أُرسل بعد آخر أجل.';

  @override
  String get workSentNotice => 'تمّ إرسال العمل.';

  @override
  String get notificationHomework => 'واجب جديد';

  @override
  String get workFileUnsupported =>
      'صيغة غير مقبولة: أرسل ملف PDF أو صورة JPG أو PNG.';

  @override
  String get submissionInfo =>
      '«عرض العمل» يفتح العمل المُرسَل. التصحيح والعدد على 20 يأتيان في نسخة قادمة.';

  @override
  String parentSendsNotice(String name) {
    return 'يمكنك تصوير عمل $name وإرساله من هنا بدلًا منه.';
  }

  @override
  String get notificationCorrected => 'واجب مُصحَّح';

  @override
  String correctedSeeGrade(String group) {
    return 'وصل العدد · $group';
  }

  @override
  String get subjectAllFilter => 'المادة: الكل';

  @override
  String subjectFilter(String name) {
    return 'المادة: $name';
  }

  @override
  String toCorrectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count للتصحيح',
      many: '$count للتصحيح',
      few: '$count للتصحيح',
      two: 'اثنان للتصحيح',
      one: 'واحد للتصحيح',
      zero: 'لا شيء للتصحيح',
    );
    return '$_temp0';
  }

  @override
  String deadlineWas(String when) {
    return 'آخر أجل $when';
  }

  @override
  String get correctAction => 'تصحيح';

  @override
  String correctCount(int count) {
    return 'تصحيح ($count)';
  }

  @override
  String get toCorrectInfo =>
      'يصل هنا كل عمل مُرسل، الأقدم أولًا. يرى التلميذ وأولياؤه العدد والتعليق فور الحفظ.';

  @override
  String get toCorrectEmptyHint => 'ستصل هنا الأعمال التي يرسلها تلاميذك.';

  @override
  String copyOf(int index, int count) {
    return 'النسخة $index من $count';
  }

  @override
  String get previousCopy => 'النسخة السابقة';

  @override
  String get nextCopy => 'النسخة التالية';

  @override
  String get scoreLabel => 'العدد';

  @override
  String get scoreHint => 'مثال: 14,5';

  @override
  String scoreHelper(int max) {
    return 'عدد من 0 إلى $max، بأنصاف النقاط: 14,5.';
  }

  @override
  String scoreInvalid(int max) {
    return 'العدد من 0 إلى $max، بأنصاف النقاط.';
  }

  @override
  String get commentLabel => 'التعليق';

  @override
  String get commentSuffix => 'اختياري · يراه التلميذ وأولياؤه';

  @override
  String get correctionCommentHint => 'مثال: عمل جيّد، راجع اختزال الكسور.';

  @override
  String get phraseVeryGood => 'ممتاز!';

  @override
  String get phraseGoodWork => 'عمل جيّد';

  @override
  String get phraseReviewLesson => 'راجع الدرس';

  @override
  String get phraseHandwriting => 'حسّن خطّك';

  @override
  String get correctedCopy => 'النسخة المصحّحة';

  @override
  String get takeCorrectedPhoto => 'التقاط صورة';

  @override
  String get removeCopy => 'إزالة';

  @override
  String get saveAndNext => 'حفظ والتالي';

  @override
  String nextCopyName(String name) {
    return 'النسخة التالية: $name';
  }

  @override
  String get lastCopy => 'هذه آخر نسخة للتصحيح في هذا الواجب.';

  @override
  String get correctionSaved => 'تمّ حفظ التصحيح.';

  @override
  String get allCorrected => 'صُحّحت كل نسخ هذا الواجب.';

  @override
  String get noWorkPane =>
      'لم يُرسل شيء. يمكنك إسناد عدد لنسخة سُلّمت على الورق.';

  @override
  String get columnScore => 'العدد';

  @override
  String get viewCorrection => 'عرض';

  @override
  String get gradeAnyway => 'إسناد عدد';

  @override
  String get tileCorrected => 'مُصحَّحة';

  @override
  String averageOutOf20(String value) {
    return 'المعدّل $value / 20';
  }

  @override
  String get gradeAnywayInfo =>
      '«إسناد عدد» لتلميذ لم يُرسل شيئًا: نسخة سُلّمت على الورق مثلًا. الواجب دون عدد لا يُحتسب أبدًا صفرًا في المعدّل.';

  @override
  String get yourGrade => 'عددك';

  @override
  String childGrade(String name) {
    return 'عدد $name';
  }

  @override
  String correctedOn(String when) {
    return 'صُحّح $when';
  }

  @override
  String get myResultsTitle => 'نتائجي';

  @override
  String get myResultsSubtitle => 'أعدادك وعملك، مادّة بمادّة.';

  @override
  String parentResultsTitle(String name) {
    return 'نتائج $name';
  }

  @override
  String parentResultsSubtitle(String name) {
    return 'أعداد $name وعمله، مادّة بمادّة.';
  }

  @override
  String averageOfGrades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المعدّل من $count عدد',
      many: 'المعدّل من $count عددًا',
      few: 'المعدّل من $count أعداد',
      two: 'المعدّل من عددين',
      one: 'عدد واحد',
      zero: 'لا يوجد عدد',
    );
    return '$_temp0';
  }

  @override
  String get trendUp => 'في تحسّن';

  @override
  String get trendDown => 'في تراجع';

  @override
  String get trendStable => 'مستقرّ';

  @override
  String countOf(int count, int total) {
    return '$count من $total';
  }

  @override
  String get homeworkSentLabel => 'واجبات مُرسلة';

  @override
  String get attendanceLabel => 'الحضور';

  @override
  String get gradesTitle => 'الأعداد';

  @override
  String get resultsEmpty => 'لا توجد نتائج بعد: ستصل أعدادك هنا.';

  @override
  String resultsEmptyParent(String name) {
    return 'لا توجد نتائج لـ$name بعد.';
  }

  @override
  String missingTitle(String title) {
    return 'لم يُرسل: $title';
  }

  @override
  String get seeResults => 'عرض النتائج';

  @override
  String get evaluationsTab => 'التقييمات';

  @override
  String get newEvaluation => 'تقييم جديد';

  @override
  String get newEvaluationSubtitle =>
      'اختبار في القسم على الورق: تُدخل أعداد المجموعة بعد ذلك.';

  @override
  String get editEvaluation => 'تعديل التقييم';

  @override
  String get evaluationTitleHint => 'مثال: تقييم الضرب';

  @override
  String get evaluationTitleHelp =>
      'يرى التلاميذ والأولياء هذا العنوان مع العدد.';

  @override
  String get notedOn => 'العدد من';

  @override
  String get scaleOther => 'آخر';

  @override
  String get scaleOtherLabel => 'السلّم';

  @override
  String get scaleOtherHint => 'مثال: 40';

  @override
  String get scaleInvalid => 'بين 1 و100.';

  @override
  String get evaluationScaleNote =>
      'يُحتسب العدد في معدّل المادّة مثل عدد الواجب. العدد من 10 يُحوَّل إلى 20 في المعدّل.';

  @override
  String get createAndGrade => 'إنشاء وإدخال الأعداد';

  @override
  String get noChapter => 'دون فصل';

  @override
  String gradesTyped(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عدد من $total',
      many: '$count عددًا من $total',
      few: '$count أعداد من $total',
      two: 'عددان من $total',
      one: 'عدد واحد من $total',
      zero: 'لا أعداد من $total',
    );
    return '$_temp0';
  }

  @override
  String get gradesToType => 'أعداد للإدخال';

  @override
  String get gradesDone => 'أعداد مُدخلة';

  @override
  String get groupAverage => 'معدّل المجموعة';

  @override
  String get absentLabel => 'غائب';

  @override
  String get toType => 'للإدخال';

  @override
  String get columnAbsent => 'غائب';

  @override
  String get columnComment => 'تعليق';

  @override
  String get commentForPupilHint => 'كلمة للتلميذ (اختياري)';

  @override
  String get saveGrades => 'حفظ الأعداد';

  @override
  String get gradesSaved => 'تم حفظ الأعداد.';

  @override
  String scoreTooHigh(String max) {
    return 'على الأكثر $max.';
  }

  @override
  String get scoreHalfPoints => 'عدد بأنصاف النقاط: 14 أو 14,5.';

  @override
  String get keyboardHint =>
      'زر Tab ينقل إلى التلميذ الموالي وShift + Tab يرجع وEntrée يحفظ. تُكتب أنصاف النقاط هكذا: 11,5.';

  @override
  String get absentNeverZero =>
      '«غائب» لا يُحتسب أبدًا صفرًا. عند الحفظ، يرى التلاميذ وأولياؤهم أعدادهم والتعليق.';

  @override
  String outOf(String max) {
    return 'من $max';
  }

  @override
  String get unsavedGradesTitle => 'الخروج دون حفظ؟';

  @override
  String get unsavedGradesText => 'ستضيع الأعداد المكتوبة منذ آخر حفظ.';

  @override
  String get leaveWithoutSaving => 'خروج';

  @override
  String get noEvaluations => 'لا توجد تقييمات حاليًا.';

  @override
  String get noEvaluationsHint =>
      'اختبار على الورق؟ أنشئه هنا وأدخل أعداد المجموعة بلوحة المفاتيح.';

  @override
  String get gradeKindEvaluation => 'تقييم';

  @override
  String get gradeKindHomework => 'واجب';

  @override
  String get notificationEvaluation => 'عدد جديد';

  @override
  String evaluationSeeGrade(String group) {
    return 'وصل عدد في $group.';
  }

  @override
  String gradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عدد',
      many: '$count عددًا',
      few: '$count أعداد',
      two: 'عددان',
      one: 'عدد واحد',
      zero: 'لا يوجد عدد',
    );
    return '$_temp0';
  }

  @override
  String get dayContentEmpty => 'لا توجد وثيقة مُشاركة مع هذه المجموعة حاليًا.';

  @override
  String notificationWorkSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عمل مُرسل',
      many: '$count عملًا مُرسلًا',
      few: '$count أعمال مُرسلة',
      two: 'عملان مُرسلان',
      one: 'عمل واحد مُرسل',
      zero: 'لا عمل مُرسل',
    );
    return '$_temp0';
  }

  @override
  String get notificationDeadlinePassed => 'انقضى آخر أجل';

  @override
  String get workLate => 'متأخّر';

  @override
  String get everyoneSent => 'أرسل الجميع';

  @override
  String missingPupils(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لم يُرسل $count: $names',
      one: 'لم يُرسل تلميذ واحد: $names',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String namesAnd(String first, String last) {
    return '$first و$last';
  }

  @override
  String namesAndOthers(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$names و$count آخرين',
      many: '$names و$count آخرين',
      few: '$names و$count آخرين',
      two: '$names وآخران',
      one: '$names وآخر',
      zero: '$names',
    );
    return '$_temp0';
  }

  @override
  String get actionSee => 'عرض';

  @override
  String get noNotificationsTeacher => 'لا جديد في الوقت الحالي.';

  @override
  String get noNotificationsHintTeacher =>
      'سيصلك إشعار هنا عندما يرسل تلميذ عملًا أو ينقضي آخر أجل.';

  @override
  String get quickEvaluation => 'تقييم';

  @override
  String get importTitle => 'استيراد التلاميذ';

  @override
  String importReadLines(String file, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سطر مقروء',
      many: '$count سطرًا مقروءًا',
      few: '$count أسطر مقروءة',
      two: 'سطران مقروءان',
      one: 'سطر واحد مقروء',
      zero: 'لم يُقرأ أيّ سطر',
    );
    return '$file · $_temp0. تثبّت قبل إنشاء التلاميذ.';
  }

  @override
  String get importStepFile => 'الملف';

  @override
  String get importStepCheck => 'التثبّت';

  @override
  String get importStepAccounts => 'الحسابات';

  @override
  String importStepOf(int step, String name) {
    return 'الخطوة $step من 3 · $name';
  }

  @override
  String get importChooseTitle => 'اختر ملفك';

  @override
  String get importChooseHint =>
      'ملف Excel أو CSV، 300 سطر على الأكثر. لا يُنشأ أيّ شيء قبل التثبّت.';

  @override
  String get importReading => 'جارٍ قراءة الملف…';

  @override
  String get importTemplate => 'تنزيل النموذج';

  @override
  String get importColumnsTitle => 'الأعمدة المنتظرة';

  @override
  String get importColumnsHint =>
      'سطر لكلّ تلميذ. يمكن أن تكون أسماء الأعمدة بالعربية أو بالفرنسية. * إجباري.';

  @override
  String get importColFirstName => 'الاسم';

  @override
  String get importColLastName => 'اللقب';

  @override
  String get importColParentFirstName => 'اسم الوليّ';

  @override
  String get importColParentLastName => 'لقب الوليّ';

  @override
  String get importColParentPhone => 'هاتف الوليّ';

  @override
  String get importTipSiblings =>
      'وليّ له عدّة أبناء: الهاتف نفسه في كلّ سطر، ويُنشأ حساب واحد.';

  @override
  String get importTipNoParent =>
      'دون وليّ يُضاف التلميذ رغم ذلك، ويمكنك فتح حساب لاحقًا من بطاقته.';

  @override
  String get importForAll => 'لكلّ تلاميذ الملف';

  @override
  String get importGroup => 'إضافة إلى المجموعة';

  @override
  String get importNoGroup => 'دون مجموعة';

  @override
  String get importGroupHelp => 'يُعتمد عمود «المجموعة» في الملف أيضًا.';

  @override
  String get importLevel => 'المستوى عندما يكون العمود فارغًا';

  @override
  String get importCreateLogins => 'إنشاء حسابات التلاميذ أيضًا';

  @override
  String get importCreateLoginsHelp =>
      'وإلّا يحصل الأولياء وحدهم على حساب (بهاتفهم). يمكنك فتح حساب تلميذ من بطاقته.';

  @override
  String get importReadyCount => 'جاهزون للاستيراد';

  @override
  String get importKnownCount => 'وليّ مسجّل، رُبط';

  @override
  String get importExistsCount => 'مسجّل، تُرك';

  @override
  String get importErrorCount => 'للتصحيح في الملف';

  @override
  String get importColumnLine => 'السطر';

  @override
  String get importColumnParent => 'الوليّ';

  @override
  String get importColumnState => 'الحالة';

  @override
  String get importStateReady => 'جاهز';

  @override
  String get importStateKnown => 'وليّ مسجّل';

  @override
  String get importStateExists => 'مسجّل';

  @override
  String get importStateError => 'للتصحيح';

  @override
  String importKnownNote(String parent, String child) {
    return 'حساب $parent موجود: يُضاف $child إلى أبنائه.';
  }

  @override
  String importExistsNote(String name) {
    return '$name ضمن تلاميذك: أشّر على السطر لإضافته رغم ذلك.';
  }

  @override
  String importSameParentNote(int line) {
    return 'الوليّ نفسه في السطر $line: حساب واحد.';
  }

  @override
  String get importProblemFirstName => 'الاسم ناقص.';

  @override
  String get importProblemLastName => 'اللقب ناقص.';

  @override
  String get importProblemLevelMissing =>
      'المستوى ناقص: اختر مستوى لكامل الملف.';

  @override
  String importProblemLevelUnknown(String text) {
    return 'مستوى غير معروف: «$text». من السنة الأولى إلى السادسة.';
  }

  @override
  String importProblemGroupUnknown(String text) {
    return 'مجموعة غير معروفة: «$text».';
  }

  @override
  String get importProblemPhoneInvalid => 'هاتف التلميذ: 8 أرقام.';

  @override
  String get importProblemPhoneTaken => 'هاتف التلميذ مستعمل في حساب آخر.';

  @override
  String get importProblemParentPhoneMissing => 'هاتف الوليّ ناقص: هو معرّفه.';

  @override
  String get importProblemParentPhoneInvalid => 'هاتف الوليّ: 8 أرقام.';

  @override
  String get importProblemParentPhoneTaken => 'هاتف الوليّ مستعمل في حساب آخر.';

  @override
  String get importProblemParentName => 'اسم الوليّ ولقبه ناقصان.';

  @override
  String importProblemDuplicate(int line) {
    return 'التلميذ نفسه في السطر $line.';
  }

  @override
  String get importErrorsNote =>
      'لا تُستورد الأسطر «للتصحيح»: صحّحها في ملفك ثمّ اختره من جديد، أو استورد البقية الآن وأضف هؤلاء التلاميذ لاحقًا.';

  @override
  String importSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُضاف $count تلميذ',
      many: 'سيُضاف $count تلميذًا',
      few: 'سيُضاف $count تلاميذ',
      two: 'سيُضاف تلميذان',
      one: 'سيُضاف تلميذ واحد',
      zero: 'لم يُؤشَّر أيّ تلميذ.',
    );
    return '$_temp0';
  }

  @override
  String importSummaryParents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '، مع $count حساب وليّ جديد.',
      many: '، مع $count حسابًا جديدًا للأولياء.',
      few: '، مع $count حسابات أولياء جديدة.',
      two: '، مع حسابَي وليّين جديدين.',
      one: '، مع حساب وليّ جديد.',
      zero: '.',
    );
    return '$_temp0';
  }

  @override
  String get importAnotherFile => 'اختيار ملف آخر';

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استيراد $count تلميذ',
      many: 'استيراد $count تلميذًا',
      few: 'استيراد $count تلاميذ',
      two: 'استيراد تلميذين',
      one: 'استيراد تلميذ واحد',
      zero: 'استيراد',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُضيف $count تلميذ',
      many: 'أُضيف $count تلميذًا',
      few: 'أُضيف $count تلاميذ',
      two: 'أُضيف تلميذان',
      one: 'أُضيف تلميذ واحد',
      zero: 'لم يُضف أيّ تلميذ',
    );
    return '$_temp0';
  }

  @override
  String importAddedTo(String title, String group) {
    return '$title إلى $group';
  }

  @override
  String importDoneParents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب وليّ جديد.',
      many: '$count حسابًا جديدًا للأولياء.',
      few: '$count حسابات أولياء جديدة.',
      two: 'حسابا وليّين جديدان.',
      one: 'حساب وليّ جديد.',
      zero: 'لا حساب وليّ جديد.',
    );
    return '$_temp0';
  }

  @override
  String importDoneLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' انضمّ $count طفل إلى أولياء مسجّلين.',
      many: ' انضمّ $count طفلًا إلى أولياء مسجّلين.',
      few: ' انضمّ $count أطفال إلى أولياء مسجّلين.',
      two: ' انضمّ طفلان إلى أولياء مسجّلين.',
      one: ' انضمّ طفل إلى وليّ مسجّل.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get importCopyAll => 'نسخ الكلّ';

  @override
  String get importPrint => 'طباعة';

  @override
  String get importPrintNote =>
      'يختار كلّ واحد كلمة عبوره عند أوّل دخول. «طباعة» تُعدّ بطاقة لكلّ عائلة تُقصّ وتُسلَّم في القسم.';

  @override
  String get importNoAccounts =>
      'لا حساب جديد لتسليمه: انضمّ الأطفال إلى أولياء مسجّلين أو ليس لهم وليّ.';

  @override
  String get importAgain => 'استيراد ملف آخر';

  @override
  String get importSeeStudents => 'عرض تلاميذي';

  @override
  String printCardTitle(String name) {
    return 'حساب $name';
  }

  @override
  String get printCardHelp =>
      'افتح NG Class، أدخل المعرّف وكلمة العبور هذه، ثمّ اختر كلمتك.';

  @override
  String get printFileName => 'حسابات NG Class';

  @override
  String get searchParents => 'الأولياء';

  @override
  String get searchHomeworkSection => 'الواجبات والتقييمات';

  @override
  String get searchKeysChoose => 'للاختيار';

  @override
  String get searchKeysOpen => 'للفتح';

  @override
  String get searchKeysClose => 'للإغلاق';

  @override
  String get searchEverywhere => 'في كلّ مكان:';

  @override
  String get searchKeyEnter => 'إدخال';

  @override
  String get searchKeyEscape => 'Esc';

  @override
  String searchNothing(String query) {
    return 'لا نتيجة لـ«$query»';
  }

  @override
  String get searchNothingHint =>
      'ابحث عن تلميذ (الاسم، المعرّف، هاتف الوليّ)، أو مجموعة، أو وثيقة، أو فصل، أو واجب، أو تقييم.';

  @override
  String get searchOpen => 'بحث';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get linkCopied => 'تمّ نسخ الرابط.';
}
