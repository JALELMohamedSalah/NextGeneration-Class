// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NextGeneration Class';

  @override
  String get appShortName => 'NG Class';

  @override
  String get tagline => 'Enseigner, suivre, progresser.';

  @override
  String get loading => 'Chargement…';

  @override
  String get loginSubtitle =>
      'Connectez-vous avec l\'identifiant donné par votre enseignante.';

  @override
  String get loginIdentifierLabel => 'Identifiant ou téléphone';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginIdentifierRequired =>
      'Saisissez votre identifiant ou votre téléphone.';

  @override
  String get loginPasswordRequired => 'Saisissez votre mot de passe.';

  @override
  String get loginForgotHint =>
      'Mot de passe oublié ? Demandez à votre enseignante de le réinitialiser.';

  @override
  String get loginFeaturePlanning => 'Planning et présences';

  @override
  String get loginFeatureWork => 'Devoirs et corrections';

  @override
  String get loginFeatureProgress => 'Suivi des progrès';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get errorNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get errorUnknown => 'Une erreur est survenue. Réessayez.';

  @override
  String get navTeacherHome => 'Ma journée';

  @override
  String get navPlanning => 'Planning';

  @override
  String get navStudents => 'Élèves';

  @override
  String get navContents => 'Contenus';

  @override
  String get navAssignments => 'Devoirs';

  @override
  String get navAnnouncements => 'Annonces';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navMore => 'Plus';

  @override
  String get navStudentHome => 'Accueil';

  @override
  String get navCourses => 'Cours';

  @override
  String get navResults => 'Résultats';

  @override
  String get navParentOverview => 'Aperçu';

  @override
  String get navNotifications => 'Notifications';

  @override
  String greeting(String firstName) {
    return 'Bonjour $firstName';
  }

  @override
  String get homeToday => 'Aujourd\'hui';

  @override
  String get homeToCorrect => 'À corriger';

  @override
  String get homeMissing => 'Travail manquant';

  @override
  String get homeUpcoming => 'À venir';

  @override
  String get emptyToday => 'Aucune séance aujourd\'hui.';

  @override
  String get emptyToCorrect => 'Rien à corriger. Bonne journée !';

  @override
  String get emptyMissing => 'Tous les devoirs sont rendus.';

  @override
  String get emptyUpcoming => 'Rien de prévu dans les 7 prochains jours.';

  @override
  String get quickCreate => 'Créer';

  @override
  String get quickSession => 'Séance';

  @override
  String get quickAssignment => 'Devoir';

  @override
  String get quickSeries => 'Série';

  @override
  String get comingSoonMessage =>
      'Cette section arrive avec une prochaine version de l\'application.';

  @override
  String get accountMenu => 'Mon compte';

  @override
  String get language => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get roleTeacher => 'Enseignante';

  @override
  String get roleStudent => 'Élève';

  @override
  String get roleParent => 'Parent';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get temporaryPassword => 'Mot de passe temporaire';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordRule =>
      'Au moins 8 caractères, avec des lettres et des chiffres.';

  @override
  String get passwordsDoNotMatch =>
      'Les deux mots de passe ne sont pas identiques.';

  @override
  String get passwordChanged => 'Mot de passe modifié.';

  @override
  String get fieldRequired => 'Ce champ est obligatoire.';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get mustChangePasswordTitle => 'Choisissez votre mot de passe';

  @override
  String get mustChangePasswordMessage =>
      'Votre enseignante vous a donné un mot de passe temporaire. Choisissez-en un nouveau pour continuer.';

  @override
  String get nextSession => 'Prochaine séance';

  @override
  String get noSessionPlanned => 'Aucune séance prévue pour le moment.';

  @override
  String get toDo => 'À faire';

  @override
  String get nothingToDo => 'Rien à faire pour le moment.';

  @override
  String get latestResults => 'Derniers résultats';

  @override
  String get noGradeYet => 'Pas encore de note.';

  @override
  String get attendance => 'Présence';

  @override
  String get assignments => 'Devoirs';

  @override
  String get parentNoChild =>
      'Aucun enfant n\'est lié à ce compte. Contactez l\'enseignante.';

  @override
  String get parentNoDataYet =>
      'Les informations apparaîtront ici dès les premières séances.';

  @override
  String get loginOverline => 'Espace privé';

  @override
  String get loginWelcome => 'Bon retour';

  @override
  String get loginBrandLine =>
      'L\'espace privé de votre enseignante, pour ses élèves et leurs parents.';

  @override
  String get loginFeaturePlanningText =>
      'Séances, liens Meet et appel en un geste.';

  @override
  String get loginFeatureWorkText =>
      'Rendus, file de correction, notes sur 20.';

  @override
  String get loginFeatureProgressText =>
      'Les parents comprennent tout en une minute.';

  @override
  String get firstLoginOverline => 'Première connexion';

  @override
  String get footerCopyright => '© NextGeneration Class';

  @override
  String get languageToggleShort => 'FR · ع';

  @override
  String get searchPlaceholder => 'Rechercher un élève, un contenu…';

  @override
  String get myGroups => 'Mes groupes';

  @override
  String get homeSummaryEmpty =>
      'Rien de prévu pour l\'instant. Ajoutez vos élèves et vos séances pour remplir votre journée.';

  @override
  String get heroToday => 'Aujourd\'hui';

  @override
  String get heroFreeDayTitle => 'Journée libre';

  @override
  String get heroFreeDayText => 'Aucune séance prévue aujourd\'hui.';

  @override
  String get planSession => 'Planifier une séance';

  @override
  String get quickQcm => 'QCM';

  @override
  String get quickImport => 'Importer';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get emptyComment => 'Aucun commentaire pour le moment.';

  @override
  String get teacherNote => 'Mot de l\'enseignante';

  @override
  String get noValue => '—';

  @override
  String releaseBadge(int number) {
    return 'Version $number';
  }

  @override
  String get comingPlanning =>
      'Calendrier de la semaine, séances récurrentes, liens Meet et présences.';

  @override
  String get comingStudents =>
      'Élèves, parents, groupes et cours particuliers, avec leurs identifiants.';

  @override
  String get comingAssignments =>
      'Devoirs, rendus des élèves et file de correction.';

  @override
  String get comingAnnouncements =>
      'Annonces aux groupes, aux élèves et aux parents.';

  @override
  String get comingStudentAssignments =>
      'Vos devoirs, quiz et séries, avec leur date limite.';

  @override
  String get comingStudentPlanning =>
      'Vos prochaines séances, en présentiel ou en ligne.';

  @override
  String get comingResults =>
      'Vos notes, les commentaires et votre progression.';

  @override
  String get comingParentPlanning => 'Les prochaines séances de votre enfant.';

  @override
  String daySessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '1 séance',
      zero: '0 séance',
    );
    return '$_temp0';
  }

  @override
  String childThisWeek(String name) {
    return '$name cette semaine';
  }

  @override
  String get average => 'Moyenne';

  @override
  String get lastGrade => 'Dernière note';

  @override
  String get notYet => 'Pas encore';

  @override
  String get retry => 'Réessayer';

  @override
  String get add => 'Ajouter';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get delete => 'Supprimer';

  @override
  String get optional => 'facultatif';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié.';

  @override
  String get listSeparator => ', ';

  @override
  String get dotSeparator => ' · ';

  @override
  String get savedChanges => 'Modifications enregistrées.';

  @override
  String get noResults => 'Aucun résultat.';

  @override
  String percentValue(int value) {
    return '$value %';
  }

  @override
  String timeRange(String start, String end) {
    return '$start à $end';
  }

  @override
  String untilTime(String time) {
    return 'jusqu\'à $time';
  }

  @override
  String inDuration(String duration) {
    return 'dans $duration';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String todayDate(String date) {
    return 'Aujourd\'hui, $date';
  }

  @override
  String tomorrowDate(String date) {
    return 'Demain, $date';
  }

  @override
  String everyWeekday(String weekday) {
    return 'Chaque $weekday';
  }

  @override
  String get statusPlanned => 'Prévue';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusDone => 'Terminée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusNext => 'Prochaine';

  @override
  String get modeInPerson => 'Présentiel';

  @override
  String get modeOnline => 'En ligne';

  @override
  String get attendancePresent => 'Présent';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceLate => 'En retard';

  @override
  String presentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count présents',
      one: '1 présent',
      zero: '0 présent',
    );
    return '$_temp0';
  }

  @override
  String absentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absents',
      one: '1 absent',
      zero: '0 absent',
    );
    return '$_temp0';
  }

  @override
  String lateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en retard',
      one: '1 en retard',
      zero: '0 en retard',
    );
    return '$_temp0';
  }

  @override
  String absencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absences',
      one: '1 absence',
      zero: 'Aucune absence',
    );
    return '$_temp0';
  }

  @override
  String studentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves',
      one: '1 élève',
      zero: 'Aucun élève',
    );
    return '$_temp0';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
      zero: 'aucun groupe',
    );
    return '$_temp0';
  }

  @override
  String privateLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cours particuliers',
      one: '1 cours particulier',
      zero: 'aucun cours particulier',
    );
    return '$_temp0';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '1 séance',
      zero: 'Aucune séance',
    );
    return '$_temp0';
  }

  @override
  String get tabGroups => 'Groupes';

  @override
  String get tabPrivateLessons => 'Cours particuliers';

  @override
  String get tabArchived => 'Archivés';

  @override
  String studentsYearSummary(String students, String groups, String lessons) {
    return '$students, $groups et $lessons cette année.';
  }

  @override
  String get newStudent => 'Nouvel élève';

  @override
  String get newGroup => 'Nouveau groupe';

  @override
  String get searchStudents => 'Nom, identifiant, téléphone';

  @override
  String get levelAll => 'Niveau : tous';

  @override
  String levelFilter(String level) {
    return 'Niveau : $level';
  }

  @override
  String get columnStudent => 'Élève';

  @override
  String get columnGroups => 'Groupes';

  @override
  String get columnParent => 'Parent';

  @override
  String get columnAttendance => 'Présence';

  @override
  String get noParent => 'Aucun parent';

  @override
  String get noGroup => 'Aucun groupe';

  @override
  String get emptyStudents => 'Aucun élève pour le moment. Ajoutez le premier.';

  @override
  String get emptyArchived => 'Aucun élève archivé.';

  @override
  String get emptyGroups => 'Aucun groupe pour le moment. Créez le premier.';

  @override
  String get emptyPrivateLessons =>
      'Aucun cours particulier. Créez-en un depuis la fiche d\'un élève.';

  @override
  String get restore => 'Restaurer';

  @override
  String get noSchedule => 'Aucun horaire habituel';

  @override
  String get addStudentsHint => 'Ajoutez des élèves';

  @override
  String get privateLesson => 'Cours particulier';

  @override
  String get studentFormSubtitle =>
      'Ses identifiants s\'affichent après l\'enregistrement.';

  @override
  String get editStudent => 'Modifier l\'élève';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get level => 'Niveau';

  @override
  String get chooseLevel => 'Choisir un niveau';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneHint => '8 chiffres';

  @override
  String get phoneInvalid => 'Le numéro doit contenir 8 chiffres.';

  @override
  String get username => 'Identifiant';

  @override
  String get usernameHint =>
      'Créé à partir du prénom et du nom. Vous pouvez le changer.';

  @override
  String get usernameAvailable => 'Disponible';

  @override
  String get usernameTaken => 'Déjà utilisé';

  @override
  String get groups => 'Groupes';

  @override
  String get addGroup => 'Ajouter un groupe';

  @override
  String get parents => 'Parents';

  @override
  String parentsCount(int count) {
    return '$count sur 2';
  }

  @override
  String get existingParent => 'Parent existant';

  @override
  String get newParent => 'Nouveau parent';

  @override
  String get relation => 'Lien';

  @override
  String get relationMother => 'mère';

  @override
  String get relationFather => 'père';

  @override
  String get relationGuardian => 'tuteur';

  @override
  String get email => 'Email';

  @override
  String get newAccount => 'Nouveau compte';

  @override
  String get searchParent => 'Rechercher un parent';

  @override
  String parentOf(String children) {
    return 'Parent de $children';
  }

  @override
  String get noParentsYet => 'Aucun parent enregistré pour l\'instant.';

  @override
  String get parentLinked => 'Déjà lié';

  @override
  String get credentialsTitle => 'Identifiants créés';

  @override
  String get credentialsSubtitle =>
      'Envoyez-les maintenant : les mots de passe ne seront plus affichés.';

  @override
  String get resetPasswordTitle => 'Nouveau mot de passe temporaire';

  @override
  String get credentialUsername => 'Identifiant';

  @override
  String get credentialPassword => 'Mot de passe temporaire';

  @override
  String get copyMessage => 'Copier le message';

  @override
  String get credentialsNote =>
      'Chacun choisira son propre mot de passe à la première connexion. En cas d\'oubli : Fiche élève, Réinitialiser le mot de passe.';

  @override
  String get credentialsDone => 'J\'ai envoyé les identifiants';

  @override
  String get parentLoginNote => 'se connecte avec son téléphone';

  @override
  String credentialsMessage(
    String name,
    String app,
    String username,
    String password,
  ) {
    return 'Bonjour $name, voici vos accès à $app.\nIdentifiant : $username\nMot de passe temporaire : $password\nVous choisirez votre propre mot de passe à la première connexion.';
  }

  @override
  String get active => 'Actif';

  @override
  String get archivedStatus => 'Archivé';

  @override
  String usernameInline(String username) {
    return 'identifiant $username';
  }

  @override
  String lastLogin(String when) {
    return 'dernière connexion $when';
  }

  @override
  String get neverLoggedIn => 'jamais connecté';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get archive => 'Archiver';

  @override
  String archiveStudentTitle(String name) {
    return 'Archiver $name ?';
  }

  @override
  String get archiveStudentText =>
      'Il ne pourra plus se connecter et disparaîtra des listes. Rien n\'est supprimé : vous pourrez le restaurer.';

  @override
  String studentArchived(String name) {
    return '$name est archivé.';
  }

  @override
  String studentRestored(String name) {
    return '$name est de retour.';
  }

  @override
  String resetPasswordConfirm(String name) {
    return '$name devra choisir un nouveau mot de passe. Ses appareils seront déconnectés.';
  }

  @override
  String get statAttendance => 'Présence cette année';

  @override
  String get statLate => 'Retards';

  @override
  String get statSessions => 'Séances comptées';

  @override
  String get sinceSeptember => 'depuis septembre';

  @override
  String get nextSessions => 'Prochaines séances';

  @override
  String get noUpcoming => 'Aucune séance prévue.';

  @override
  String get attendanceTitle => 'Présences';

  @override
  String get lastTenSessions => '10 dernières séances';

  @override
  String get noAttendanceYet => 'Pas encore de présence enregistrée.';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get commentsVisibility => 'Visible par l\'élève et ses parents';

  @override
  String get commentHint => 'Un mot pour l\'élève et ses parents…';

  @override
  String get privateNotesTitle => 'Notes privées';

  @override
  String get privateNotesVisibility => 'Visible par vous uniquement';

  @override
  String get noPrivateNotes => 'Aucune note privée.';

  @override
  String get noteHint => 'Écrivez votre note…';

  @override
  String get deleteNoteTitle => 'Supprimer cette note ?';

  @override
  String get createPrivateLesson => 'Créer un cours particulier';

  @override
  String privateLessonText(String name) {
    return 'Un groupe pour $name seul, dans la matière choisie.';
  }

  @override
  String get privateLessonCreated => 'Cours particulier créé.';

  @override
  String get subject => 'Matière';

  @override
  String get chooseSubject => 'Choisir une matière';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get groupNameHint => 'Ex. : 4ème année · Maths';

  @override
  String get groupFormSubtitle =>
      'Vous ajouterez les élèves et l\'horaire ensuite.';

  @override
  String get editGroup => 'Modifier le groupe';

  @override
  String get color => 'Couleur';

  @override
  String get defaultMeetLink => 'Lien Meet par défaut';

  @override
  String get meetLinkHint => 'https://meet.google.com/…';

  @override
  String get meetLinkInvalid => 'Le lien doit commencer par https://';

  @override
  String get addMembers => 'Ajouter des élèves';

  @override
  String get groupMembersTitle => 'Élèves du groupe';

  @override
  String get usualSchedule => 'Horaire habituel';

  @override
  String scheduleNote(String date) {
    return 'Séances créées jusqu\'au $date. Une séance se modifie seule ou avec les suivantes.';
  }

  @override
  String get noScheduleYet =>
      'Pas d\'horaire habituel. Planifiez une séance et cochez Répéter chaque semaine.';

  @override
  String get noMeetLink => 'Aucun lien. Les séances sont en présentiel.';

  @override
  String get archiveGroup => 'Archiver le groupe';

  @override
  String get archiveGroupText =>
      'Le groupe disparaît des listes. Ses séances passées restent dans l\'historique des élèves.';

  @override
  String get groupArchived => 'Groupe archivé.';

  @override
  String get noMembers => 'Aucun élève dans ce groupe.';

  @override
  String get chooseStudents => 'Choisir les élèves';

  @override
  String selectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String get saveMembers => 'Enregistrer';

  @override
  String get viewDay => 'Jour';

  @override
  String get viewWeek => 'Semaine';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get allGroups => 'Tous les groupes';

  @override
  String get newSession => 'Nouvelle séance';

  @override
  String get planningLegend =>
      'Atténuée : terminée · Barrée : annulée · Cliquez sur un créneau vide pour ajouter une séance';

  @override
  String get emptyWeek => 'Aucune séance cette semaine.';

  @override
  String get emptyDay => 'Aucune séance ce jour-là.';

  @override
  String get editSession => 'Modifier la séance';

  @override
  String get group => 'Groupe';

  @override
  String get chooseGroup => 'Choisir un groupe';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Début';

  @override
  String get endTime => 'Fin';

  @override
  String get mode => 'Mode';

  @override
  String get location => 'Lieu';

  @override
  String get locationHint => 'Ex. : Salle 2';

  @override
  String get meetLink => 'Lien visio';

  @override
  String get fromGroup => 'Du groupe';

  @override
  String get repeatWeekly => 'Répéter chaque semaine';

  @override
  String repeatWeeklyHint(String weekday, String date) {
    return 'Chaque $weekday jusqu\'au $date';
  }

  @override
  String get repeatUntil => 'Jusqu\'au';

  @override
  String get sessionsToCreate => 'Séances créées';

  @override
  String createSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer $count séances',
      one: 'Créer la séance',
      zero: 'Créer',
    );
    return '$_temp0';
  }

  @override
  String overlapWarning(String session) {
    return 'Chevauche une séance : $session. Vous pouvez continuer.';
  }

  @override
  String get prepNotes => 'Notes de préparation';

  @override
  String get prepNotesHint => 'Ce que vous voulez revoir…';

  @override
  String get timeRangeInvalid =>
      'L\'heure de fin doit être après l\'heure de début.';

  @override
  String get noGroupsYet => 'Créez d\'abord un groupe dans Élèves.';

  @override
  String sessionsCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances créées.',
      one: 'Séance créée.',
      zero: 'Aucune séance créée.',
    );
    return '$_temp0';
  }

  @override
  String get sessionUpdated => 'Séance modifiée.';

  @override
  String get startSession => 'Démarrer la séance';

  @override
  String get resumeSession => 'Reprendre la séance';

  @override
  String get openMeet => 'Ouvrir Meet';

  @override
  String everyWeekdayUntil(String weekday, String date) {
    return 'Chaque $weekday, jusqu\'au $date';
  }

  @override
  String get cancelSession => 'Annuler la séance';

  @override
  String get restoreSession => 'Rétablir la séance';

  @override
  String cancelledBecause(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get seriesNote => 'Cette séance fait partie d\'une série.';

  @override
  String get scopeOne => 'Cette séance uniquement';

  @override
  String get scopeFollowing => 'Cette séance et les suivantes';

  @override
  String scopeFollowingCount(String count, String date) {
    return '$count jusqu\'au $date';
  }

  @override
  String get cancelReason => 'Motif';

  @override
  String get cancelReasonVisibility => 'affiché à l\'élève et à ses parents';

  @override
  String get cancelReasonHint => 'Ex. : examen au lycée';

  @override
  String get cancelVisibleNote =>
      'Les élèves et leurs parents sont prévenus dans l\'application et voient le motif dans leur planning.';

  @override
  String get sessionCancelled => 'Séance annulée.';

  @override
  String get sessionRestored => 'Séance rétablie.';

  @override
  String get editAttendance => 'Modifier les présences';

  @override
  String inProgressFor(int minutes) {
    return 'En cours · $minutes min';
  }

  @override
  String get endSession => 'Terminer la séance';

  @override
  String get tapToChange => 'Touchez un élève pour changer';

  @override
  String get contentOfDay => 'Contenu du jour';

  @override
  String lastSessionOn(String day) {
    return 'Dernière séance · $day';
  }

  @override
  String get noPreviousNote => 'Pas de note sur la dernière séance.';

  @override
  String get quickNote => 'Note rapide';

  @override
  String get quickNoteHint =>
      'Ce qui s\'est passé, à revoir la prochaine fois…';

  @override
  String get noteSaved => 'Enregistrée';

  @override
  String get noteSaving => 'Enregistrement…';

  @override
  String get endSessionTitle => 'Terminer la séance ?';

  @override
  String endSessionText(String summary) {
    return 'Présences enregistrées : $summary.';
  }

  @override
  String get sessionEnded => 'Séance terminée.';

  @override
  String get joinSession => 'Rejoindre la séance';

  @override
  String childSessions(String name) {
    return 'Séances de $name';
  }

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String cancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count annulées',
      one: '1 annulée',
      zero: 'Aucune annulée',
    );
    return '$_temp0';
  }

  @override
  String absencesThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absences ce mois',
      one: '1 absence ce mois',
      zero: 'Aucune absence ce mois',
    );
    return '$_temp0';
  }

  @override
  String get emptyMyPlanning =>
      'Aucune séance dans les deux prochaines semaines.';

  @override
  String todayInDuration(String duration) {
    return 'Aujourd\'hui, dans $duration';
  }

  @override
  String homeSessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances aujourd\'hui.',
      one: '1 séance aujourd\'hui.',
      zero: 'Aucune séance aujourd\'hui.',
    );
    return '$_temp0';
  }

  @override
  String tomorrowSessions(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Demain : $count séances, la première à $time.',
      one: 'Demain : 1 séance, à $time.',
      zero: 'Demain : aucune séance.',
    );
    return '$_temp0';
  }

  @override
  String attendanceOf(int present, int total) {
    return 'présences $present sur $total';
  }

  @override
  String get childAccess => 'Accès de l\'élève';

  @override
  String get childAccessHint =>
      'Facultatif. Les élèves du primaire n\'en ont souvent pas besoin : leurs parents suivent tout.';

  @override
  String get createChildAccess => 'Créer un accès';

  @override
  String get removeChildAccess => 'Retirer l\'accès';

  @override
  String removeChildAccessText(String name) {
    return '$name ne pourra plus se connecter. Ses parents continuent de tout suivre.';
  }

  @override
  String get childAccessRemoved => 'Accès retiré.';

  @override
  String get noChildAccess => 'sans accès, suivi par ses parents';

  @override
  String get newSubject => 'Nouvelle matière';

  @override
  String get subjectNameFr => 'Nom en français';

  @override
  String get subjectNameAr => 'Nom en arabe';

  @override
  String get subjectNameHint =>
      'Ex. : Mathématiques, Lecture, Éveil scientifique';

  @override
  String get subjectNameArHint =>
      'S\'il est vide, le nom français est affiché.';

  @override
  String get subjectCreated => 'Matière créée.';

  @override
  String get settingsSubtitle =>
      'Les matières que vous enseignez, vos niveaux et l\'année scolaire.';

  @override
  String get yourSubjects => 'Vos matières';

  @override
  String get subjectNoArabicName =>
      'Pas de nom arabe : le nom français est affiché';

  @override
  String get subjectInUse =>
      'Utilisée par un groupe : elle ne peut pas être supprimée.';

  @override
  String get subjectDeleteRule =>
      'Une matière utilisée par un groupe ne peut pas être supprimée : changez d\'abord la matière du groupe.';

  @override
  String get editSubject => 'Modifier la matière';

  @override
  String get subjectUpdated => 'Matière modifiée.';

  @override
  String deleteSubjectTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteSubjectText =>
      'Aucun groupe ne l\'utilise. Cette suppression est définitive.';

  @override
  String get subjectDeleted => 'Matière supprimée.';

  @override
  String get levelsTitle => 'Niveaux';

  @override
  String get primarySchool => 'Primaire';

  @override
  String get levelsNote =>
      'Les six années du primaire tunisien, en français et en arabe.';

  @override
  String get schoolYearTitle => 'Année scolaire';

  @override
  String schoolYearRange(String start, String end) {
    return 'du $start au $end';
  }

  @override
  String get noSubjectsYet =>
      'Aucune matière pour l\'instant. Créez la première.';

  @override
  String get loginIdentifierHint => 'Identifiant ou numéro';

  @override
  String get loginPasswordHint => 'Votre mot de passe';

  @override
  String notificationsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lues',
      one: '1 non lue',
      zero: 'Tout est lu',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsToday => 'Aujourd\'hui';

  @override
  String get notificationsEarlier => 'Plus tôt';

  @override
  String notificationCancelled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances annulées',
      one: 'Séance annulée',
      zero: 'Aucune séance annulée',
    );
    return '$_temp0';
  }

  @override
  String notificationMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances déplacées',
      one: 'Séance déplacée',
      zero: 'Aucune séance déplacée',
    );
    return '$_temp0';
  }

  @override
  String get notificationRestored => 'Séance rétablie';

  @override
  String fromDate(String date) {
    return 'À partir du $date';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count min',
      one: 'Il y a 1 min',
      zero: 'À l\'instant',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count h',
      one: 'Il y a 1 h',
      zero: 'À l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String get noNotifications => 'Aucune notification pour le moment.';

  @override
  String get noNotificationsHint =>
      'Vous serez prévenu ici si une séance est annulée, déplacée ou rétablie.';

  @override
  String get familiesWillBeTold =>
      'Si la date ou l\'heure change, les élèves et les parents seront prévenus dans l\'application.';

  @override
  String get modeInClass => 'En classe';

  @override
  String weekSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette semaine, il te reste $count séances.',
      one: 'Cette semaine, il te reste 1 séance.',
      zero: 'Plus de séance cette semaine.',
    );
    return '$_temp0';
  }

  @override
  String get whatsNew => 'Du nouveau';

  @override
  String get myWeek => 'Ma semaine';

  @override
  String get seePlanning => 'Voir le planning';

  @override
  String get legendSession => 'Séance';

  @override
  String nextWeekSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'La semaine prochaine : $count séances.',
      one: 'La semaine prochaine : 1 séance.',
      zero: 'Pas de séance la semaine prochaine.',
    );
    return '$_temp0';
  }

  @override
  String get nextWeek => 'Semaine prochaine';

  @override
  String get laterOn => 'Plus tard';

  @override
  String tomorrowWeekday(String weekday) {
    return 'Demain, $weekday';
  }

  @override
  String get newTime => 'Nouvel horaire';

  @override
  String previousTime(String when) {
    return 'Avant : $when';
  }

  @override
  String dayAtTime(String day, String time) {
    return '$day à $time';
  }

  @override
  String get joinOpensBefore => 'Le lien pour rejoindre apparaît 15 min avant.';

  @override
  String get noNotificationsHintStudent =>
      'Tu seras prévenu ici si une séance est annulée, déplacée ou rétablie.';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get navTeachers => 'Enseignants';

  @override
  String get adminArea => 'Administration';

  @override
  String get teachersSubtitle =>
      'Chaque enseignant travaille dans son propre espace, avec ses élèves et leurs parents.';

  @override
  String get newTeacher => 'Nouvel enseignant';

  @override
  String teachersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enseignants',
      one: '1 enseignant',
      zero: 'Aucun enseignant',
    );
    return '$_temp0';
  }

  @override
  String activeAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes actifs',
      one: '1 compte actif',
      zero: 'Aucun compte actif',
    );
    return '$_temp0';
  }

  @override
  String get statStudents => 'Élèves suivis';

  @override
  String get statParents => 'Comptes parents';

  @override
  String get statGroups => 'Groupes en cours';

  @override
  String get allSpaces => 'Tous les espaces';

  @override
  String get searchTeachers => 'Nom, identifiant, téléphone';

  @override
  String get columnTeacher => 'Enseignant';

  @override
  String get columnStatus => 'Statut';

  @override
  String get columnStudents => 'Élèves';

  @override
  String get columnLastLogin => 'Dernière connexion';

  @override
  String get teacherActive => 'Actif';

  @override
  String get teacherTemporaryPassword => 'Mot de passe temporaire';

  @override
  String get teacherDisabled => 'Désactivé';

  @override
  String get lastLoginNever => 'Jamais connecté';

  @override
  String get teacherActions => 'Actions';

  @override
  String get disableAccess => 'Désactiver l\'accès';

  @override
  String get enableAccess => 'Réactiver l\'accès';

  @override
  String disableTeacherTitle(String name) {
    return 'Désactiver l\'accès de $name ?';
  }

  @override
  String get disableTeacherText =>
      'La connexion à ce compte sera bloquée. Ses élèves et leurs parents gardent leur accès. Rien n\'est supprimé : vous pourrez le réactiver.';

  @override
  String teacherDisabledNotice(String name) {
    return 'Accès de $name désactivé.';
  }

  @override
  String teacherEnabledNotice(String name) {
    return 'Accès de $name réactivé.';
  }

  @override
  String get newTeacherSubtitle =>
      'Un identifiant et un mot de passe temporaire sont créés pour la première connexion.';

  @override
  String get teacherUsernameHint =>
      'Pour se connecter. Le téléphone sert aussi, s\'il est indiqué.';

  @override
  String get usernameRule =>
      '3 caractères au moins : lettres sans accent, chiffres, point, tiret.';

  @override
  String get createTeacherAccount => 'Créer le compte';

  @override
  String get noTeachers => 'Aucun enseignant pour le moment.';

  @override
  String get noTeachersHint =>
      'Ajoutez le premier : un identifiant et un mot de passe temporaire lui sont donnés.';

  @override
  String get teacherCredentialsNote =>
      'Le mot de passe temporaire n\'est montré qu\'une fois. L\'enseignant choisit le sien à la première connexion. En cas d\'oubli : Actions, Réinitialiser le mot de passe.';

  @override
  String get studentFirstNameHint => 'Ex. : Adam';

  @override
  String get parentFirstNameHint => 'Ex. : Mouna';

  @override
  String get teacherFirstNameHint => 'Ex. : Sonia';

  @override
  String get lastNameHint => 'Ex. : Gharbi';

  @override
  String get teacherLastNameHint => 'Ex. : Ben Ali';

  @override
  String get studentUsernameExample => 'Ex. : adam.gharbi';

  @override
  String get teacherUsernameExample => 'Ex. : sonia.benali';

  @override
  String get emailHint => 'Ex. : nom@exemple.com';

  @override
  String get subjectNameArExample => 'مثال: الرياضيات';

  @override
  String get relationHint => 'Mère, père, tuteur';

  @override
  String get temporaryPasswordHint => 'Le mot de passe reçu';

  @override
  String get currentPasswordHint => 'Celui utilisé pour se connecter';

  @override
  String get newPasswordHint => 'Facile à retenir, difficile à deviner';

  @override
  String get confirmPasswordHint => 'Le même, une seconde fois';

  @override
  String get contentsSubtitle =>
      'Vos documents, rangés par matière, niveau et chapitre.';

  @override
  String get newChapter => 'Nouveau chapitre';

  @override
  String get importDocument => 'Importer un document';

  @override
  String get importShort => 'Importer';

  @override
  String get shareChapter => 'Partager le chapitre';

  @override
  String get unfiled => 'Sans chapitre';

  @override
  String get searchTitle => 'Rechercher un titre';

  @override
  String get tagAll => 'Étiquette : toutes';

  @override
  String tagFilter(String tag) {
    return 'Étiquette : $tag';
  }

  @override
  String get statusAll => 'Statut : tous';

  @override
  String statusFilter(String status) {
    return 'Statut : $status';
  }

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'Aucun document',
    );
    return '$_temp0';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
      zero: 'Aucune page',
    );
    return '$_temp0';
  }

  @override
  String get columnDocument => 'Document';

  @override
  String get columnTag => 'Étiquette';

  @override
  String get columnSharedWith => 'Partagé avec';

  @override
  String get columnEdited => 'Modifié';

  @override
  String get notShared => 'Non partagé';

  @override
  String get tagSerie => 'Série';

  @override
  String get tagCours => 'Cours';

  @override
  String get tagCorrige => 'Corrigé';

  @override
  String get tagAutre => 'Autre';

  @override
  String get statusPublished => 'Publié';

  @override
  String get statusDraft => 'Brouillon';

  @override
  String get kindPdf => 'PDF';

  @override
  String get kindImage => 'Photo';

  @override
  String get kindWord => 'Word';

  @override
  String get toDownload => 'à télécharger';

  @override
  String sizeKb(String value) {
    return '$value Ko';
  }

  @override
  String sizeMb(String value) {
    return '$value Mo';
  }

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionEditDetails => 'Modifier les détails';

  @override
  String get renameChapter => 'Renommer le chapitre';

  @override
  String get deleteChapter => 'Supprimer le chapitre';

  @override
  String get documentActions => 'Actions sur le document';

  @override
  String get chapterActions => 'Actions sur le chapitre';

  @override
  String archiveDocumentTitle(String title) {
    return 'Archiver « $title » ?';
  }

  @override
  String get archiveDocumentText =>
      'Il disparaît de la bibliothèque et des onglets Cours. Rien n\'est supprimé.';

  @override
  String deleteChapterTitle(String title) {
    return 'Supprimer le chapitre « $title » ?';
  }

  @override
  String get deleteChapterText =>
      'Ses documents restent, dans « Sans chapitre ». Le partage du chapitre s\'arrête.';

  @override
  String get documentArchived => 'Document archivé.';

  @override
  String get chapterDeleted => 'Chapitre supprimé.';

  @override
  String get documentUploaded => 'Document importé.';

  @override
  String get detailsSaved => 'Modifications enregistrées.';

  @override
  String get shareSaved => 'Partage enregistré.';

  @override
  String get libraryEmptyTitle => 'Votre bibliothèque est vide.';

  @override
  String get libraryEmptyHint =>
      'Importez une série, une leçon ou une photo du tableau, puis partagez-la avec un groupe.';

  @override
  String get chapterEmpty => 'Aucun document dans ce chapitre.';

  @override
  String get subjectEmpty =>
      'Aucun document dans cette matière pour l\'instant.';

  @override
  String get draftCannotShare =>
      'Un brouillon ne peut pas être partagé. Publiez-le d\'abord.';

  @override
  String get importSubtitle =>
      'Une classe entière d\'un coup, depuis Excel : les élèves, leurs parents et leurs accès.';

  @override
  String get editDetailsSubtitle => 'Titre, rangement, étiquette et statut.';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get changeFile => 'Changer';

  @override
  String get fileUnsupported =>
      'Format non accepté : choisissez un PDF, une photo JPG ou PNG, ou un fichier Word.';

  @override
  String get fileTooLarge => 'Ce fichier dépasse 20 Mo.';

  @override
  String get fileEmpty => 'Ce fichier est vide.';

  @override
  String get fileRequired => 'Choisissez un fichier.';

  @override
  String get documentTitle => 'Titre';

  @override
  String get documentTitleHint => 'Ex. : Série 2 : les fractions';

  @override
  String get documentTitleHelper => 'Les élèves voient ce titre.';

  @override
  String get chapter => 'Chapitre';

  @override
  String get tag => 'Étiquette';

  @override
  String get shareWith => 'Partager avec';

  @override
  String get shareWithHint =>
      'Les élèves de ces groupes le voient dans Cours. Vous pourrez partager plus tard.';

  @override
  String get keepDraft => 'Garder en brouillon';

  @override
  String get keepDraftHint =>
      'Un brouillon n\'est jamais visible par les élèves.';

  @override
  String uploadProgress(int percent) {
    return 'Envoi : $percent %';
  }

  @override
  String get chapterTitle => 'Titre du chapitre';

  @override
  String get chapterTitleHint => 'Ex. : Les fractions';

  @override
  String shareDocumentTitle(String title) {
    return 'Partager « $title »';
  }

  @override
  String shareChapterTitle(String title) {
    return 'Partager le chapitre « $title »';
  }

  @override
  String get shareSubtitle =>
      'Les élèves des groupes cochés le voient dans leur onglet Cours.';

  @override
  String get shareChapterSubtitle =>
      'Tous ses documents publiés, et ceux ajoutés ensuite.';

  @override
  String groupsOfLevel(String level) {
    return 'Groupes de $level';
  }

  @override
  String get otherGroups => 'Autres groupes';

  @override
  String get unshareNote =>
      'Décocher un groupe retire le document de son onglet Cours. Rien n\'est supprimé.';

  @override
  String get download => 'Télécharger';

  @override
  String pageOf(int page, int count) {
    return 'Page $page sur $count';
  }

  @override
  String get previousPage => 'Page précédente';

  @override
  String get nextPage => 'Page suivante';

  @override
  String get zoomIn => 'Agrandir';

  @override
  String get zoomOut => 'Réduire';

  @override
  String get details => 'Détails';

  @override
  String get detailFile => 'Fichier';

  @override
  String get wordNoPreview =>
      'Un fichier Word ne s\'ouvre pas dans l\'application. Téléchargez-le pour le lire.';

  @override
  String get downloadFailed => 'Le téléchargement n\'a pas pu démarrer.';

  @override
  String get pageNotShown => 'Cette page ne s\'affiche pas.';

  @override
  String get myCoursesTitle => 'Mes cours';

  @override
  String get myCoursesSubtitle => 'Ce qui a été partagé avec toi, par matière.';

  @override
  String parentCoursesTitle(String name) {
    return 'Cours pour $name';
  }

  @override
  String parentCoursesSubtitle(String name) {
    return 'Les documents partagés avec $name. Vous pouvez les ouvrir et les imprimer.';
  }

  @override
  String get allSubjects => 'Tout';

  @override
  String get newBadge => 'Nouveau';

  @override
  String get coursEmpty => 'Rien n\'est encore partagé avec toi.';

  @override
  String coursEmptyParent(String name) {
    return 'Rien n\'est encore partagé avec $name.';
  }

  @override
  String get scanSheets => 'Scanner des feuilles';

  @override
  String get scanSheetsHint => 'Plusieurs pages, un seul PDF';

  @override
  String get fileTypesShort => 'PDF, JPG, PNG, Word';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get addPhotos => 'Ajouter des photos';

  @override
  String get scanHint =>
      'Posez la feuille à plat, bien éclairée. Appuyez sur une page pour la recadrer ou la pivoter, maintenez-la pour la déplacer.';

  @override
  String get scanColor => 'Couleur';

  @override
  String get scanBlackWhite => 'Noir et blanc';

  @override
  String get createPdf => 'Créer le PDF';

  @override
  String get scanEmptyTitle => 'Prenez la première feuille en photo.';

  @override
  String get scanEmptyHint =>
      'Une photo par feuille. Vous pourrez recadrer, pivoter et changer l\'ordre.';

  @override
  String get scanPreparing => 'Préparation…';

  @override
  String get scanDiscardTitle => 'Abandonner le scan ?';

  @override
  String get scanDiscardText => 'Les photos prises ici seront perdues.';

  @override
  String get scanDiscard => 'Abandonner';

  @override
  String get rotate => 'Pivoter';

  @override
  String get resetCrop => 'Rétablir';

  @override
  String get validate => 'Valider';

  @override
  String get deletePage => 'Supprimer la page';

  @override
  String get cropHint =>
      'Faites glisser les coins sur les bords de la feuille.';

  @override
  String scanFileName(String date) {
    return 'Scan du $date';
  }

  @override
  String get scanPhotoFailed => 'Une photo n\'a pas pu être lue.';

  @override
  String get scanPdfFailed => 'Le PDF n\'a pas pu être créé.';

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get cropCorner => 'Coin de la feuille';

  @override
  String get scanEmptyTitleComputer => 'Ajoutez les photos de vos feuilles.';

  @override
  String get scanEmptyHintComputer =>
      'Choisissez les photos déjà prises, une par feuille. Vous pourrez recadrer, pivoter et changer l\'ordre.';

  @override
  String get homeworkSubtitle =>
      'Ce que vos élèves ont à faire, et qui l\'a rendu.';

  @override
  String get newHomework => 'Nouveau devoir';

  @override
  String get homeworkOpen => 'En cours';

  @override
  String get homeworkDone => 'Terminés';

  @override
  String get groupAll => 'Groupe : tous';

  @override
  String groupFilter(String name) {
    return 'Groupe : $name';
  }

  @override
  String get columnHomework => 'Devoir';

  @override
  String get columnDueFor => 'Pour le';

  @override
  String get columnSent => 'Rendus';

  @override
  String sentOf(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rendus sur $total',
      one: '1 rendu sur $total',
      zero: 'Aucun rendu sur $total',
    );
    return '$_temp0';
  }

  @override
  String missingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count manquants',
      one: '1 manquant',
      zero: 'Aucun manquant',
    );
    return '$_temp0';
  }

  @override
  String get nothingToSubmit => 'Rien à rendre';

  @override
  String get toRead => 'À lire';

  @override
  String dueToday(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String dueTomorrow(String time) {
    return 'Demain, $time';
  }

  @override
  String dueOn(String date, String time) {
    return '$date, $time';
  }

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count jours',
      one: 'demain',
      zero: 'aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'hier',
      zero: 'aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get homeworkInfo =>
      'Après la date limite, un devoir non rendu passe en « Manquant » tout seul. Les élèves et leurs parents voient chaque nouveau devoir dans leurs notifications.';

  @override
  String get homeworkEmpty => 'Aucun devoir en cours.';

  @override
  String get homeworkEmptyHint =>
      'Donnez un document de vos Contenus à un groupe, avec une date limite.';

  @override
  String get homeworkDoneEmpty => 'Aucun devoir terminé pour l\'instant.';

  @override
  String get newHomeworkSubtitle =>
      'Un document de la bibliothèque, pour un groupe ou quelques élèves, avec une date limite.';

  @override
  String get documentLabel => 'Document';

  @override
  String get chooseDocument => 'Choisir un document';

  @override
  String get noPublishedDocuments =>
      'Importez d\'abord un document dans Contenus.';

  @override
  String get homeworkTitleHelper =>
      'Pris du document. Les élèves voient ce titre.';

  @override
  String get forLabel => 'Pour';

  @override
  String get forGroup => 'Un groupe';

  @override
  String get forStudents => 'Des élèves';

  @override
  String get pickStudentsRequired => 'Cochez au moins un élève.';

  @override
  String get deadlineDate => 'Date limite';

  @override
  String get deadlineTime => 'Heure';

  @override
  String get deadlineInPast => 'Choisissez une date limite à venir.';

  @override
  String get submissionLabel => 'Rendu';

  @override
  String get modeFile => 'Photos ou PDF';

  @override
  String get modeNone => 'Rien à rendre';

  @override
  String get modeFileHint =>
      'Les élèves prennent leur cahier en photo : les pages deviennent un seul PDF.';

  @override
  String get modeNoneHint => 'Un document à lire, sans statut.';

  @override
  String get instructionsLabel => 'Consignes';

  @override
  String get instructionsHint =>
      'Ex. : Fais les exercices 1 à 3 sur ton cahier.';

  @override
  String get allowLate => 'Accepter les rendus en retard';

  @override
  String get allowLateHint => 'Ils sont marqués « Rendu en retard ».';

  @override
  String get giveHomework => 'Donner le devoir';

  @override
  String get homeworkGiven => 'Devoir donné.';

  @override
  String get giveAsHomework => 'Donner en devoir';

  @override
  String get hwStatusTodo => 'À faire';

  @override
  String get hwStatusSubmitted => 'Rendu';

  @override
  String get hwStatusLate => 'Rendu en retard';

  @override
  String get hwStatusMissing => 'Manquant';

  @override
  String get hwStatusCorrected => 'Corrigé';

  @override
  String get tileSubmitted => 'Rendus';

  @override
  String get tileLate => 'Rendus en retard';

  @override
  String get tileMissing => 'Manquants';

  @override
  String get tileTodo => 'À faire';

  @override
  String get columnSentAt => 'Rendu le';

  @override
  String get viewWork => 'Voir le rendu';

  @override
  String get nothingReceived => 'Rien reçu';

  @override
  String get changeDeadline => 'Changer la date';

  @override
  String get closeHomework => 'Clore';

  @override
  String closeHomeworkTitle(String title) {
    return 'Clore « $title » ?';
  }

  @override
  String get closeHomeworkText =>
      'Plus aucun travail ne pourra être envoyé. Ce qui a été envoyé reste.';

  @override
  String get homeworkClosed => 'Devoir clos.';

  @override
  String get deadlineChanged => 'Date limite changée.';

  @override
  String get lateAccepted => 'Retard accepté';

  @override
  String get closedChip => 'Clos';

  @override
  String dueFor(String when) {
    return 'Pour le $when';
  }

  @override
  String get newDeadline => 'Nouvelle date limite';

  @override
  String get myHomeworkTitle => 'Mes devoirs';

  @override
  String get myHomeworkSubtitle =>
      'Ce que tu as à faire, le plus pressé en premier.';

  @override
  String parentHomeworkTitle(String name) {
    return 'Devoirs pour $name';
  }

  @override
  String parentHomeworkSubtitle(String name) {
    return 'Ce que $name a à faire, et ce qui a été envoyé.';
  }

  @override
  String get sectionTodo => 'À faire';

  @override
  String get sectionDone => 'Terminés';

  @override
  String dueLabel(String when) {
    return 'Pour $when';
  }

  @override
  String sentOn(String when) {
    return 'Rendu $when';
  }

  @override
  String readBefore(String when) {
    return 'À lire avant $when';
  }

  @override
  String get myHomeworkEmpty => 'Aucun devoir pour l\'instant.';

  @override
  String parentHomeworkEmpty(String name) {
    return 'Aucun devoir pour $name pour l\'instant.';
  }

  @override
  String get yourWork => 'Ton travail';

  @override
  String childWork(String name) {
    return 'Le travail de $name';
  }

  @override
  String get workPhotosHint =>
      'Une photo par page du cahier : elles deviennent un seul PDF.';

  @override
  String get takeMyWork => 'Prendre mon travail en photo';

  @override
  String get takeTheWork => 'Prendre le travail en photo';

  @override
  String get orChooseFile => 'Ou choisir un fichier';

  @override
  String get replaceMyWork => 'Remplacer mon travail';

  @override
  String get replaceTheWork => 'Remplacer le travail';

  @override
  String get workSent => 'C\'est envoyé !';

  @override
  String get myWork => 'Mon travail';

  @override
  String get sentWork => 'Travail envoyé';

  @override
  String canReplaceUntilTu(String when) {
    return 'Tu peux le remplacer jusqu\'à $when.';
  }

  @override
  String canReplaceUntil(String when) {
    return 'Vous pouvez le remplacer jusqu\'à $when.';
  }

  @override
  String get deadlinePassedNotice =>
      'La date limite est passée : le devoir ne peut plus être envoyé.';

  @override
  String get closedNotice => 'Ce devoir est clos.';

  @override
  String get readOnlyNotice => 'Rien à rendre : il suffit de lire le document.';

  @override
  String get missingNotice => 'Rien n\'a été envoyé avant la date limite.';

  @override
  String get lateSentNotice => 'Envoyé après la date limite.';

  @override
  String get workSentNotice => 'Travail envoyé.';

  @override
  String get notificationHomework => 'Nouveau devoir';

  @override
  String get workFileUnsupported =>
      'Format non accepté : envoyez un PDF ou une photo JPG ou PNG.';

  @override
  String get submissionInfo =>
      '« Voir le rendu » ouvre le travail envoyé. La correction et la note sur 20 arrivent avec une prochaine version.';

  @override
  String parentSendsNotice(String name) {
    return 'Vous pouvez photographier le travail de $name et l\'envoyer ici, à sa place.';
  }

  @override
  String get notificationCorrected => 'Devoir corrigé';

  @override
  String correctedSeeGrade(String group) {
    return 'La note est arrivée · $group';
  }

  @override
  String get subjectAllFilter => 'Matière : toutes';

  @override
  String subjectFilter(String name) {
    return 'Matière : $name';
  }

  @override
  String toCorrectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à corriger',
      one: '1 à corriger',
      zero: 'Rien à corriger',
    );
    return '$_temp0';
  }

  @override
  String deadlineWas(String when) {
    return 'date limite $when';
  }

  @override
  String get correctAction => 'Corriger';

  @override
  String correctCount(int count) {
    return 'Corriger ($count)';
  }

  @override
  String get toCorrectInfo =>
      'Chaque travail envoyé arrive ici, le plus ancien en premier. La note et le commentaire sont visibles par l\'élève et ses parents dès l\'enregistrement.';

  @override
  String get toCorrectEmptyHint =>
      'Les travaux envoyés par vos élèves arriveront ici.';

  @override
  String copyOf(int index, int count) {
    return 'Copie $index sur $count';
  }

  @override
  String get previousCopy => 'Copie précédente';

  @override
  String get nextCopy => 'Copie suivante';

  @override
  String get scoreLabel => 'Note';

  @override
  String get scoreHint => 'Ex. : 14,5';

  @override
  String scoreHelper(int max) {
    return 'Un nombre de 0 à $max, demi-points acceptés : 14,5.';
  }

  @override
  String scoreInvalid(int max) {
    return 'La note va de 0 à $max, par demi-points.';
  }

  @override
  String get commentLabel => 'Commentaire';

  @override
  String get commentSuffix =>
      'facultatif · visible par l\'élève et ses parents';

  @override
  String get correctionCommentHint =>
      'Ex. : Bon travail, revois la simplification des fractions.';

  @override
  String get phraseVeryGood => 'Très bien !';

  @override
  String get phraseGoodWork => 'Bon travail';

  @override
  String get phraseReviewLesson => 'Revois la leçon';

  @override
  String get phraseHandwriting => 'Soigne l\'écriture';

  @override
  String get correctedCopy => 'Copie corrigée';

  @override
  String get takeCorrectedPhoto => 'Prendre en photo';

  @override
  String get removeCopy => 'Retirer';

  @override
  String get saveAndNext => 'Enregistrer et suivant';

  @override
  String nextCopyName(String name) {
    return 'Copie suivante : $name';
  }

  @override
  String get lastCopy => 'C\'est la dernière copie à corriger de ce devoir.';

  @override
  String get correctionSaved => 'Correction enregistrée.';

  @override
  String get allCorrected => 'Toutes les copies de ce devoir sont corrigées.';

  @override
  String get noWorkPane =>
      'Rien n\'a été envoyé. Vous pouvez noter une copie rendue sur papier.';

  @override
  String get columnScore => 'Note';

  @override
  String get viewCorrection => 'Voir';

  @override
  String get gradeAnyway => 'Noter';

  @override
  String get tileCorrected => 'Corrigés';

  @override
  String averageOutOf20(String value) {
    return 'Moyenne $value / 20';
  }

  @override
  String get gradeAnywayInfo =>
      '« Noter » un élève sans rendu : une copie rendue sur papier, par exemple. Un devoir sans note ne compte jamais comme 0 dans la moyenne.';

  @override
  String get yourGrade => 'Ta note';

  @override
  String childGrade(String name) {
    return 'La note de $name';
  }

  @override
  String correctedOn(String when) {
    return 'Corrigé $when';
  }

  @override
  String get myResultsTitle => 'Mes résultats';

  @override
  String get myResultsSubtitle =>
      'Tes notes et ton travail, matière par matière.';

  @override
  String parentResultsTitle(String name) {
    return 'Résultats de $name';
  }

  @override
  String parentResultsSubtitle(String name) {
    return 'Les notes et le travail de $name, matière par matière.';
  }

  @override
  String averageOfGrades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moyenne de $count notes',
      one: 'Une seule note',
      zero: 'Aucune note',
    );
    return '$_temp0';
  }

  @override
  String get trendUp => 'En progrès';

  @override
  String get trendDown => 'En baisse';

  @override
  String get trendStable => 'Stable';

  @override
  String countOf(int count, int total) {
    return '$count sur $total';
  }

  @override
  String get homeworkSentLabel => 'devoirs rendus';

  @override
  String get attendanceLabel => 'présence';

  @override
  String get gradesTitle => 'Notes';

  @override
  String get resultsEmpty =>
      'Pas encore de résultat : tes notes arriveront ici.';

  @override
  String resultsEmptyParent(String name) {
    return 'Pas encore de résultat pour $name.';
  }

  @override
  String missingTitle(String title) {
    return 'Manquant : $title';
  }

  @override
  String get seeResults => 'Voir les résultats';

  @override
  String get evaluationsTab => 'Évaluations';

  @override
  String get newEvaluation => 'Nouvelle évaluation';

  @override
  String get newEvaluationSubtitle =>
      'Un contrôle fait en classe, sur papier : vous saisissez les notes du groupe ensuite.';

  @override
  String get editEvaluation => 'Modifier l\'évaluation';

  @override
  String get evaluationTitleHint => 'Ex. : Évaluation : la multiplication';

  @override
  String get evaluationTitleHelp =>
      'Les élèves et les parents voient ce titre avec la note.';

  @override
  String get notedOn => 'Noté sur';

  @override
  String get scaleOther => 'Autre';

  @override
  String get scaleOtherLabel => 'Barème';

  @override
  String get scaleOtherHint => 'Ex. : 40';

  @override
  String get scaleInvalid => 'Entre 1 et 100.';

  @override
  String get evaluationScaleNote =>
      'La note compte dans la moyenne de la matière comme celle d\'un devoir. Une note sur 10 est ramenée sur 20 dans la moyenne.';

  @override
  String get createAndGrade => 'Créer et saisir les notes';

  @override
  String get noChapter => 'Aucun chapitre';

  @override
  String gradesTyped(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes sur $total',
      one: '1 note sur $total',
      zero: 'Aucune note sur $total',
    );
    return '$_temp0';
  }

  @override
  String get gradesToType => 'Notes à saisir';

  @override
  String get gradesDone => 'Notes saisies';

  @override
  String get groupAverage => 'Moyenne du groupe';

  @override
  String get absentLabel => 'Absent';

  @override
  String get toType => 'À saisir';

  @override
  String get columnAbsent => 'Absent';

  @override
  String get columnComment => 'Commentaire';

  @override
  String get commentForPupilHint => 'Un mot pour l\'élève (facultatif)';

  @override
  String get saveGrades => 'Enregistrer les notes';

  @override
  String get gradesSaved => 'Notes enregistrées.';

  @override
  String scoreTooHigh(String max) {
    return 'Au plus $max.';
  }

  @override
  String get scoreHalfPoints => 'Une note par demi-points : 14 ou 14,5.';

  @override
  String get keyboardHint =>
      'Tab passe à l\'élève suivant, Maj + Tab revient, Entrée enregistre. Les demi-points s\'écrivent 11,5.';

  @override
  String get absentNeverZero =>
      '« Absent » ne compte jamais comme 0. À l\'enregistrement, les élèves et leurs parents voient leur note et le commentaire.';

  @override
  String outOf(String max) {
    return 'Sur $max';
  }

  @override
  String get unsavedGradesTitle => 'Quitter sans enregistrer ?';

  @override
  String get unsavedGradesText =>
      'Les notes tapées depuis le dernier enregistrement seront perdues.';

  @override
  String get leaveWithoutSaving => 'Quitter';

  @override
  String get noEvaluations => 'Aucune évaluation pour le moment.';

  @override
  String get noEvaluationsHint =>
      'Un contrôle sur papier ? Créez-le ici et saisissez les notes du groupe au clavier.';

  @override
  String get gradeKindEvaluation => 'Évaluation';

  @override
  String get gradeKindHomework => 'Devoir';

  @override
  String get notificationEvaluation => 'Nouvelle note';

  @override
  String evaluationSeeGrade(String group) {
    return 'Une note est arrivée en $group.';
  }

  @override
  String gradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'Aucune note',
    );
    return '$_temp0';
  }

  @override
  String get dayContentEmpty =>
      'Aucun document partagé avec ce groupe pour l\'instant.';

  @override
  String notificationWorkSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count travaux rendus',
      one: '1 travail rendu',
      zero: 'Aucun travail rendu',
    );
    return '$_temp0';
  }

  @override
  String get notificationDeadlinePassed => 'Date limite passée';

  @override
  String get workLate => 'En retard';

  @override
  String get everyoneSent => 'Tout le monde a rendu';

  @override
  String missingPupils(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count manquants : $names',
      one: '1 manquant : $names',
      zero: 'Aucun manquant',
    );
    return '$_temp0';
  }

  @override
  String namesAnd(String first, String last) {
    return '$first et $last';
  }

  @override
  String namesAndOthers(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$names et $count autres',
      one: '$names et 1 autre',
      zero: '$names',
    );
    return '$_temp0';
  }

  @override
  String get actionSee => 'Voir';

  @override
  String get noNotificationsTeacher => 'Rien de nouveau pour le moment.';

  @override
  String get noNotificationsHintTeacher =>
      'Vous serez prévenue ici quand un élève rend un travail ou quand une date limite passe.';

  @override
  String get quickEvaluation => 'Évaluation';

  @override
  String get importTitle => 'Importer des élèves';

  @override
  String importReadLines(String file, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes lues',
      one: '1 ligne lue',
      zero: 'aucune ligne lue',
    );
    return '$file · $_temp0. Vérifiez avant de créer les élèves.';
  }

  @override
  String get importStepFile => 'Fichier';

  @override
  String get importStepCheck => 'Vérifier';

  @override
  String get importStepAccounts => 'Identifiants';

  @override
  String importStepOf(int step, String name) {
    return 'Étape $step sur 3 · $name';
  }

  @override
  String get importChooseTitle => 'Choisissez votre fichier';

  @override
  String get importChooseHint =>
      'Excel (.xlsx) ou CSV, 300 lignes au plus. Rien n\'est créé avant la vérification.';

  @override
  String get importReading => 'Lecture du fichier…';

  @override
  String get importTemplate => 'Télécharger le modèle';

  @override
  String get importColumnsTitle => 'Les colonnes attendues';

  @override
  String get importColumnsHint =>
      'Une ligne par élève. Les noms de colonnes peuvent être en français ou en arabe. * obligatoire.';

  @override
  String get importColFirstName => 'Prénom';

  @override
  String get importColLastName => 'Nom';

  @override
  String get importColParentFirstName => 'Prénom du parent';

  @override
  String get importColParentLastName => 'Nom du parent';

  @override
  String get importColParentPhone => 'Téléphone du parent';

  @override
  String get importTipSiblings =>
      'Un parent qui a plusieurs enfants : le même téléphone sur chaque ligne, un seul accès est créé.';

  @override
  String get importTipNoParent =>
      'Sans parent, l\'élève est ajouté quand même ; vous ouvrirez un accès plus tard depuis sa fiche.';

  @override
  String get importForAll => 'Pour tous les élèves du fichier';

  @override
  String get importGroup => 'Ajouter au groupe';

  @override
  String get importNoGroup => 'Aucun groupe';

  @override
  String get importGroupHelp =>
      'La colonne « Groupe » du fichier compte aussi.';

  @override
  String get importLevel => 'Niveau quand la colonne est vide';

  @override
  String get importCreateLogins => 'Créer aussi l\'accès des élèves';

  @override
  String get importCreateLoginsHelp =>
      'Sinon, seuls les parents reçoivent un accès (avec leur téléphone). Vous pourrez ouvrir celui d\'un élève depuis sa fiche.';

  @override
  String get importReadyCount => 'Prêts à importer';

  @override
  String get importKnownCount => 'Parent déjà inscrit, lié';

  @override
  String get importExistsCount => 'Déjà inscrit, ignoré';

  @override
  String get importErrorCount => 'À corriger dans le fichier';

  @override
  String get importColumnLine => 'Ligne';

  @override
  String get importColumnParent => 'Parent';

  @override
  String get importColumnState => 'État';

  @override
  String get importStateReady => 'Prêt';

  @override
  String get importStateKnown => 'Parent déjà inscrit';

  @override
  String get importStateExists => 'Déjà inscrit';

  @override
  String get importStateError => 'À corriger';

  @override
  String importKnownNote(String parent, String child) {
    return '$parent a déjà un accès : $child rejoint ses enfants.';
  }

  @override
  String importExistsNote(String name) {
    return '$name est déjà dans vos élèves : cochez la ligne pour l\'ajouter quand même.';
  }

  @override
  String importSameParentNote(int line) {
    return 'Même parent que la ligne $line : un seul accès.';
  }

  @override
  String get importProblemFirstName => 'Prénom manquant.';

  @override
  String get importProblemLastName => 'Nom manquant.';

  @override
  String get importProblemLevelMissing =>
      'Niveau manquant : choisissez-en un pour tout le fichier.';

  @override
  String importProblemLevelUnknown(String text) {
    return 'Niveau inconnu : « $text ». De la 1ère à la 6ème année.';
  }

  @override
  String importProblemGroupUnknown(String text) {
    return 'Groupe inconnu : « $text ».';
  }

  @override
  String get importProblemPhoneInvalid => 'Téléphone de l\'élève : 8 chiffres.';

  @override
  String get importProblemPhoneTaken =>
      'Le téléphone de l\'élève est celui d\'un autre compte.';

  @override
  String get importProblemParentPhoneMissing =>
      'Téléphone du parent manquant : c\'est son identifiant.';

  @override
  String get importProblemParentPhoneInvalid =>
      'Téléphone du parent : 8 chiffres.';

  @override
  String get importProblemParentPhoneTaken =>
      'Le téléphone du parent est celui d\'un autre compte.';

  @override
  String get importProblemParentName => 'Prénom et nom du parent manquants.';

  @override
  String importProblemDuplicate(int line) {
    return 'Même élève que la ligne $line.';
  }

  @override
  String get importErrorsNote =>
      'Les lignes « À corriger » ne sont pas importées : corrigez-les dans votre fichier puis choisissez-le à nouveau, ou importez les autres maintenant et ajoutez ces élèves plus tard.';

  @override
  String importSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves seront ajoutés',
      one: '1 élève sera ajouté',
      zero: 'Aucun élève coché.',
    );
    return '$_temp0';
  }

  @override
  String importSummaryParents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', avec $count nouveaux accès parents.',
      one: ', avec 1 nouvel accès parent.',
      zero: '.',
    );
    return '$_temp0';
  }

  @override
  String get importAnotherFile => 'Choisir un autre fichier';

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importer $count élèves',
      one: 'Importer 1 élève',
      zero: 'Importer',
    );
    return '$_temp0';
  }

  @override
  String importDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves ajoutés',
      one: '1 élève ajouté',
      zero: 'Aucun élève ajouté',
    );
    return '$_temp0';
  }

  @override
  String importAddedTo(String title, String group) {
    return '$title à $group';
  }

  @override
  String importDoneParents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux accès parents.',
      one: '1 nouvel accès parent.',
      zero: 'Aucun nouvel accès parent.',
    );
    return '$_temp0';
  }

  @override
  String importDoneLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' $count enfants ont rejoint un parent déjà inscrit.',
      one: ' 1 enfant a rejoint un parent déjà inscrit.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get importCopyAll => 'Tout copier';

  @override
  String get importPrint => 'Imprimer';

  @override
  String get importPrintNote =>
      'Chacun choisit son propre mot de passe à la première connexion. « Imprimer » prépare une carte par famille à découper et à donner en classe.';

  @override
  String get importNoAccounts =>
      'Aucun nouvel accès à donner : les enfants ont rejoint des parents déjà inscrits ou n\'ont pas de parent.';

  @override
  String get importAgain => 'Importer un autre fichier';

  @override
  String get importSeeStudents => 'Voir mes élèves';

  @override
  String printCardTitle(String name) {
    return 'Accès de $name';
  }

  @override
  String get printCardHelp =>
      'Ouvrez NG Class, entrez l\'identifiant et ce mot de passe, puis choisissez le vôtre.';

  @override
  String get printFileName => 'Identifiants NG Class';

  @override
  String get searchParents => 'Parents';

  @override
  String get searchHomeworkSection => 'Devoirs et évaluations';

  @override
  String get searchKeysChoose => 'pour choisir';

  @override
  String get searchKeysOpen => 'pour ouvrir';

  @override
  String get searchKeysClose => 'pour fermer';

  @override
  String get searchEverywhere => 'Partout :';

  @override
  String get searchKeyEnter => 'Entrée';

  @override
  String get searchKeyEscape => 'Échap';

  @override
  String searchNothing(String query) {
    return 'Rien pour « $query »';
  }

  @override
  String get searchNothingHint =>
      'Cherchez un élève (nom, identifiant, téléphone d\'un parent), un groupe, un document, un chapitre, un devoir ou une évaluation.';

  @override
  String get searchOpen => 'Rechercher';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Lien copié.';
}
