import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'NextGeneration Class'**
  String get appTitle;

  /// No description provided for @appShortName.
  ///
  /// In fr, this message translates to:
  /// **'NG Class'**
  String get appShortName;

  /// No description provided for @tagline.
  ///
  /// In fr, this message translates to:
  /// **'Enseigner, suivre, progresser.'**
  String get tagline;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous avec l\'identifiant donné par votre enseignante.'**
  String get loginSubtitle;

  /// No description provided for @loginIdentifierLabel.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou téléphone'**
  String get loginIdentifierLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginIdentifierRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre identifiant ou votre téléphone.'**
  String get loginIdentifierRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre mot de passe.'**
  String get loginPasswordRequired;

  /// No description provided for @loginForgotHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ? Demandez à votre enseignante de le réinitialiser.'**
  String get loginForgotHint;

  /// No description provided for @loginFeaturePlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning et présences'**
  String get loginFeaturePlanning;

  /// No description provided for @loginFeatureWork.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs et corrections'**
  String get loginFeatureWork;

  /// No description provided for @loginFeatureProgress.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des progrès'**
  String get loginFeatureProgress;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion.'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorUnknown;

  /// No description provided for @navTeacherHome.
  ///
  /// In fr, this message translates to:
  /// **'Ma journée'**
  String get navTeacherHome;

  /// No description provided for @navPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get navPlanning;

  /// No description provided for @navStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves'**
  String get navStudents;

  /// No description provided for @navContents.
  ///
  /// In fr, this message translates to:
  /// **'Contenus'**
  String get navContents;

  /// No description provided for @navAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs'**
  String get navAssignments;

  /// No description provided for @navAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Annonces'**
  String get navAnnouncements;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @navStudentHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navStudentHome;

  /// No description provided for @navCourses.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get navCourses;

  /// No description provided for @navResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get navResults;

  /// No description provided for @navParentOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get navParentOverview;

  /// No description provided for @navNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @greeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {firstName}'**
  String greeting(String firstName);

  /// No description provided for @homeToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get homeToday;

  /// No description provided for @homeToCorrect.
  ///
  /// In fr, this message translates to:
  /// **'À corriger'**
  String get homeToCorrect;

  /// No description provided for @homeMissing.
  ///
  /// In fr, this message translates to:
  /// **'Travail manquant'**
  String get homeMissing;

  /// No description provided for @homeUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get homeUpcoming;

  /// No description provided for @emptyToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance aujourd\'hui.'**
  String get emptyToday;

  /// No description provided for @emptyToCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Rien à corriger. Bonne journée !'**
  String get emptyToCorrect;

  /// No description provided for @emptyMissing.
  ///
  /// In fr, this message translates to:
  /// **'Tous les devoirs sont rendus.'**
  String get emptyMissing;

  /// No description provided for @emptyUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Rien de prévu dans les 7 prochains jours.'**
  String get emptyUpcoming;

  /// No description provided for @quickCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get quickCreate;

  /// No description provided for @quickSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance'**
  String get quickSession;

  /// No description provided for @quickAssignment.
  ///
  /// In fr, this message translates to:
  /// **'Devoir'**
  String get quickAssignment;

  /// No description provided for @quickSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get quickSeries;

  /// No description provided for @comingSoonMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette section arrive avec une prochaine version de l\'application.'**
  String get comingSoonMessage;

  /// No description provided for @accountMenu.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountMenu;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @roleTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignante'**
  String get roleTeacher;

  /// No description provided for @roleStudent.
  ///
  /// In fr, this message translates to:
  /// **'Élève'**
  String get roleStudent;

  /// No description provided for @roleParent.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @temporaryPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe temporaire'**
  String get temporaryPassword;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordRule.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères, avec des lettres et des chiffres.'**
  String get passwordRule;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne sont pas identiques.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get passwordChanged;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get fieldRequired;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @mustChangePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre mot de passe'**
  String get mustChangePasswordTitle;

  /// No description provided for @mustChangePasswordMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre enseignante vous a donné un mot de passe temporaire. Choisissez-en un nouveau pour continuer.'**
  String get mustChangePasswordMessage;

  /// No description provided for @nextSession.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine séance'**
  String get nextSession;

  /// No description provided for @noSessionPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance prévue pour le moment.'**
  String get noSessionPlanned;

  /// No description provided for @toDo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get toDo;

  /// No description provided for @nothingToDo.
  ///
  /// In fr, this message translates to:
  /// **'Rien à faire pour le moment.'**
  String get nothingToDo;

  /// No description provided for @latestResults.
  ///
  /// In fr, this message translates to:
  /// **'Derniers résultats'**
  String get latestResults;

  /// No description provided for @noGradeYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de note.'**
  String get noGradeYet;

  /// No description provided for @attendance.
  ///
  /// In fr, this message translates to:
  /// **'Présence'**
  String get attendance;

  /// No description provided for @assignments.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs'**
  String get assignments;

  /// No description provided for @parentNoChild.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enfant n\'est lié à ce compte. Contactez l\'enseignante.'**
  String get parentNoChild;

  /// No description provided for @parentNoDataYet.
  ///
  /// In fr, this message translates to:
  /// **'Les informations apparaîtront ici dès les premières séances.'**
  String get parentNoDataYet;

  /// No description provided for @loginOverline.
  ///
  /// In fr, this message translates to:
  /// **'Espace privé'**
  String get loginOverline;

  /// No description provided for @loginWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get loginWelcome;

  /// No description provided for @loginBrandLine.
  ///
  /// In fr, this message translates to:
  /// **'L\'espace privé de votre enseignante, pour ses élèves et leurs parents.'**
  String get loginBrandLine;

  /// No description provided for @loginFeaturePlanningText.
  ///
  /// In fr, this message translates to:
  /// **'Séances, liens Meet et appel en un geste.'**
  String get loginFeaturePlanningText;

  /// No description provided for @loginFeatureWorkText.
  ///
  /// In fr, this message translates to:
  /// **'Rendus, file de correction, notes sur 20.'**
  String get loginFeatureWorkText;

  /// No description provided for @loginFeatureProgressText.
  ///
  /// In fr, this message translates to:
  /// **'Les parents comprennent tout en une minute.'**
  String get loginFeatureProgressText;

  /// No description provided for @firstLoginOverline.
  ///
  /// In fr, this message translates to:
  /// **'Première connexion'**
  String get firstLoginOverline;

  /// No description provided for @footerCopyright.
  ///
  /// In fr, this message translates to:
  /// **'© NextGeneration Class'**
  String get footerCopyright;

  /// No description provided for @languageToggleShort.
  ///
  /// In fr, this message translates to:
  /// **'FR · ع'**
  String get languageToggleShort;

  /// No description provided for @searchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un élève, un contenu…'**
  String get searchPlaceholder;

  /// No description provided for @myGroups.
  ///
  /// In fr, this message translates to:
  /// **'Mes groupes'**
  String get myGroups;

  /// No description provided for @homeSummaryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien de prévu pour l\'instant. Ajoutez vos élèves et vos séances pour remplir votre journée.'**
  String get homeSummaryEmpty;

  /// No description provided for @heroToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get heroToday;

  /// No description provided for @heroFreeDayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journée libre'**
  String get heroFreeDayTitle;

  /// No description provided for @heroFreeDayText.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance prévue aujourd\'hui.'**
  String get heroFreeDayText;

  /// No description provided for @planSession.
  ///
  /// In fr, this message translates to:
  /// **'Planifier une séance'**
  String get planSession;

  /// No description provided for @quickQcm.
  ///
  /// In fr, this message translates to:
  /// **'QCM'**
  String get quickQcm;

  /// No description provided for @quickImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get quickImport;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get seeAll;

  /// No description provided for @emptyComment.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commentaire pour le moment.'**
  String get emptyComment;

  /// No description provided for @teacherNote.
  ///
  /// In fr, this message translates to:
  /// **'Mot de l\'enseignante'**
  String get teacherNote;

  /// No description provided for @noValue.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get noValue;

  /// No description provided for @releaseBadge.
  ///
  /// In fr, this message translates to:
  /// **'Version {number}'**
  String releaseBadge(int number);

  /// No description provided for @comingPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier de la semaine, séances récurrentes, liens Meet et présences.'**
  String get comingPlanning;

  /// No description provided for @comingStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves, parents, groupes et cours particuliers, avec leurs identifiants.'**
  String get comingStudents;

  /// No description provided for @comingAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs, rendus des élèves et file de correction.'**
  String get comingAssignments;

  /// No description provided for @comingAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Annonces aux groupes, aux élèves et aux parents.'**
  String get comingAnnouncements;

  /// No description provided for @comingStudentAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Vos devoirs, quiz et séries, avec leur date limite.'**
  String get comingStudentAssignments;

  /// No description provided for @comingStudentPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Vos prochaines séances, en présentiel ou en ligne.'**
  String get comingStudentPlanning;

  /// No description provided for @comingResults.
  ///
  /// In fr, this message translates to:
  /// **'Vos notes, les commentaires et votre progression.'**
  String get comingResults;

  /// No description provided for @comingParentPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Les prochaines séances de votre enfant.'**
  String get comingParentPlanning;

  /// No description provided for @daySessions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 séance} =1{1 séance} other{{count} séances}}'**
  String daySessions(int count);

  /// No description provided for @childThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'{name} cette semaine'**
  String childThisWeek(String name);

  /// No description provided for @average.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get average;

  /// No description provided for @lastGrade.
  ///
  /// In fr, this message translates to:
  /// **'Dernière note'**
  String get lastGrade;

  /// No description provided for @notYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore'**
  String get notYet;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @optional.
  ///
  /// In fr, this message translates to:
  /// **'facultatif'**
  String get optional;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Copié.'**
  String get copied;

  /// No description provided for @listSeparator.
  ///
  /// In fr, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @dotSeparator.
  ///
  /// In fr, this message translates to:
  /// **' · '**
  String get dotSeparator;

  /// No description provided for @savedChanges.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées.'**
  String get savedChanges;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat.'**
  String get noResults;

  /// No description provided for @percentValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} %'**
  String percentValue(int value);

  /// No description provided for @timeRange.
  ///
  /// In fr, this message translates to:
  /// **'{start} à {end}'**
  String timeRange(String start, String end);

  /// No description provided for @untilTime.
  ///
  /// In fr, this message translates to:
  /// **'jusqu\'à {time}'**
  String untilTime(String time);

  /// No description provided for @inDuration.
  ///
  /// In fr, this message translates to:
  /// **'dans {duration}'**
  String inDuration(String duration);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h {minutes}'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @durationHours.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @todayDate.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, {date}'**
  String todayDate(String date);

  /// No description provided for @tomorrowDate.
  ///
  /// In fr, this message translates to:
  /// **'Demain, {date}'**
  String tomorrowDate(String date);

  /// No description provided for @everyWeekday.
  ///
  /// In fr, this message translates to:
  /// **'Chaque {weekday}'**
  String everyWeekday(String weekday);

  /// No description provided for @statusPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Prévue'**
  String get statusPlanned;

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statusDone;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statusCancelled;

  /// No description provided for @statusNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine'**
  String get statusNext;

  /// No description provided for @modeInPerson.
  ///
  /// In fr, this message translates to:
  /// **'Présentiel'**
  String get modeInPerson;

  /// No description provided for @modeOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get modeOnline;

  /// No description provided for @attendancePresent.
  ///
  /// In fr, this message translates to:
  /// **'Présent'**
  String get attendancePresent;

  /// No description provided for @attendanceAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get attendanceLate;

  /// No description provided for @presentCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 présent} =1{1 présent} other{{count} présents}}'**
  String presentCount(int count);

  /// No description provided for @absentCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 absent} =1{1 absent} other{{count} absents}}'**
  String absentCount(int count);

  /// No description provided for @lateCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 en retard} =1{1 en retard} other{{count} en retard}}'**
  String lateCount(int count);

  /// No description provided for @absencesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune absence} =1{1 absence} other{{count} absences}}'**
  String absencesCount(int count);

  /// No description provided for @studentsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élève} =1{1 élève} other{{count} élèves}}'**
  String studentsCount(int count);

  /// No description provided for @groupsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun groupe} =1{1 groupe} other{{count} groupes}}'**
  String groupsCount(int count);

  /// No description provided for @privateLessonsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun cours particulier} =1{1 cours particulier} other{{count} cours particuliers}}'**
  String privateLessonsCount(int count);

  /// No description provided for @sessionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance} =1{1 séance} other{{count} séances}}'**
  String sessionsCount(int count);

  /// No description provided for @tabGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get tabGroups;

  /// No description provided for @tabPrivateLessons.
  ///
  /// In fr, this message translates to:
  /// **'Cours particuliers'**
  String get tabPrivateLessons;

  /// No description provided for @tabArchived.
  ///
  /// In fr, this message translates to:
  /// **'Archivés'**
  String get tabArchived;

  /// No description provided for @studentsYearSummary.
  ///
  /// In fr, this message translates to:
  /// **'{students}, {groups} et {lessons} cette année.'**
  String studentsYearSummary(String students, String groups, String lessons);

  /// No description provided for @newStudent.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel élève'**
  String get newStudent;

  /// No description provided for @newGroup.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get newGroup;

  /// No description provided for @searchStudents.
  ///
  /// In fr, this message translates to:
  /// **'Nom, identifiant, téléphone'**
  String get searchStudents;

  /// No description provided for @levelAll.
  ///
  /// In fr, this message translates to:
  /// **'Niveau : tous'**
  String get levelAll;

  /// No description provided for @levelFilter.
  ///
  /// In fr, this message translates to:
  /// **'Niveau : {level}'**
  String levelFilter(String level);

  /// No description provided for @columnStudent.
  ///
  /// In fr, this message translates to:
  /// **'Élève'**
  String get columnStudent;

  /// No description provided for @columnGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get columnGroups;

  /// No description provided for @columnParent.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get columnParent;

  /// No description provided for @columnAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Présence'**
  String get columnAttendance;

  /// No description provided for @noParent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun parent'**
  String get noParent;

  /// No description provided for @noGroup.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe'**
  String get noGroup;

  /// No description provided for @emptyStudents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élève pour le moment. Ajoutez le premier.'**
  String get emptyStudents;

  /// No description provided for @emptyArchived.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élève archivé.'**
  String get emptyArchived;

  /// No description provided for @emptyGroups.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe pour le moment. Créez le premier.'**
  String get emptyGroups;

  /// No description provided for @emptyPrivateLessons.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cours particulier. Créez-en un depuis la fiche d\'un élève.'**
  String get emptyPrivateLessons;

  /// No description provided for @restore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get restore;

  /// No description provided for @noSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Aucun horaire habituel'**
  String get noSchedule;

  /// No description provided for @addStudentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des élèves'**
  String get addStudentsHint;

  /// No description provided for @privateLesson.
  ///
  /// In fr, this message translates to:
  /// **'Cours particulier'**
  String get privateLesson;

  /// No description provided for @studentFormSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ses identifiants s\'affichent après l\'enregistrement.'**
  String get studentFormSubtitle;

  /// No description provided for @editStudent.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'élève'**
  String get editStudent;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @level.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get level;

  /// No description provided for @chooseLevel.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un niveau'**
  String get chooseLevel;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'8 chiffres'**
  String get phoneHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro doit contenir 8 chiffres.'**
  String get phoneInvalid;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Créé à partir du prénom et du nom. Vous pouvez le changer.'**
  String get usernameHint;

  /// No description provided for @usernameAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Déjà utilisé'**
  String get usernameTaken;

  /// No description provided for @groups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get groups;

  /// No description provided for @addGroup.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un groupe'**
  String get addGroup;

  /// No description provided for @parents.
  ///
  /// In fr, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @parentsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sur 2'**
  String parentsCount(int count);

  /// No description provided for @existingParent.
  ///
  /// In fr, this message translates to:
  /// **'Parent existant'**
  String get existingParent;

  /// No description provided for @newParent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau parent'**
  String get newParent;

  /// No description provided for @relation.
  ///
  /// In fr, this message translates to:
  /// **'Lien'**
  String get relation;

  /// No description provided for @relationMother.
  ///
  /// In fr, this message translates to:
  /// **'mère'**
  String get relationMother;

  /// No description provided for @relationFather.
  ///
  /// In fr, this message translates to:
  /// **'père'**
  String get relationFather;

  /// No description provided for @relationGuardian.
  ///
  /// In fr, this message translates to:
  /// **'tuteur'**
  String get relationGuardian;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @newAccount.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau compte'**
  String get newAccount;

  /// No description provided for @searchParent.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un parent'**
  String get searchParent;

  /// No description provided for @parentOf.
  ///
  /// In fr, this message translates to:
  /// **'Parent de {children}'**
  String parentOf(String children);

  /// No description provided for @noParentsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun parent enregistré pour l\'instant.'**
  String get noParentsYet;

  /// No description provided for @parentLinked.
  ///
  /// In fr, this message translates to:
  /// **'Déjà lié'**
  String get parentLinked;

  /// No description provided for @credentialsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants créés'**
  String get credentialsTitle;

  /// No description provided for @credentialsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-les maintenant : les mots de passe ne seront plus affichés.'**
  String get credentialsSubtitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe temporaire'**
  String get resetPasswordTitle;

  /// No description provided for @credentialUsername.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get credentialUsername;

  /// No description provided for @credentialPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe temporaire'**
  String get credentialPassword;

  /// No description provided for @copyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Copier le message'**
  String get copyMessage;

  /// No description provided for @credentialsNote.
  ///
  /// In fr, this message translates to:
  /// **'Chacun choisira son propre mot de passe à la première connexion. En cas d\'oubli : Fiche élève, Réinitialiser le mot de passe.'**
  String get credentialsNote;

  /// No description provided for @credentialsDone.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai envoyé les identifiants'**
  String get credentialsDone;

  /// No description provided for @parentLoginNote.
  ///
  /// In fr, this message translates to:
  /// **'se connecte avec son téléphone'**
  String get parentLoginNote;

  /// No description provided for @credentialsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}, voici vos accès à {app}.\nIdentifiant : {username}\nMot de passe temporaire : {password}\nVous choisirez votre propre mot de passe à la première connexion.'**
  String credentialsMessage(
    String name,
    String app,
    String username,
    String password,
  );

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @archivedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get archivedStatus;

  /// No description provided for @usernameInline.
  ///
  /// In fr, this message translates to:
  /// **'identifiant {username}'**
  String usernameInline(String username);

  /// No description provided for @lastLogin.
  ///
  /// In fr, this message translates to:
  /// **'dernière connexion {when}'**
  String lastLogin(String when);

  /// No description provided for @neverLoggedIn.
  ///
  /// In fr, this message translates to:
  /// **'jamais connecté'**
  String get neverLoggedIn;

  /// No description provided for @resetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPassword;

  /// No description provided for @archive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get archive;

  /// No description provided for @archiveStudentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archiver {name} ?'**
  String archiveStudentTitle(String name);

  /// No description provided for @archiveStudentText.
  ///
  /// In fr, this message translates to:
  /// **'Il ne pourra plus se connecter et disparaîtra des listes. Rien n\'est supprimé : vous pourrez le restaurer.'**
  String get archiveStudentText;

  /// No description provided for @studentArchived.
  ///
  /// In fr, this message translates to:
  /// **'{name} est archivé.'**
  String studentArchived(String name);

  /// No description provided for @studentRestored.
  ///
  /// In fr, this message translates to:
  /// **'{name} est de retour.'**
  String studentRestored(String name);

  /// No description provided for @resetPasswordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'{name} devra choisir un nouveau mot de passe. Ses appareils seront déconnectés.'**
  String resetPasswordConfirm(String name);

  /// No description provided for @statAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Présence cette année'**
  String get statAttendance;

  /// No description provided for @statLate.
  ///
  /// In fr, this message translates to:
  /// **'Retards'**
  String get statLate;

  /// No description provided for @statSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances comptées'**
  String get statSessions;

  /// No description provided for @sinceSeptember.
  ///
  /// In fr, this message translates to:
  /// **'depuis septembre'**
  String get sinceSeptember;

  /// No description provided for @nextSessions.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines séances'**
  String get nextSessions;

  /// No description provided for @noUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance prévue.'**
  String get noUpcoming;

  /// No description provided for @attendanceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Présences'**
  String get attendanceTitle;

  /// No description provided for @lastTenSessions.
  ///
  /// In fr, this message translates to:
  /// **'10 dernières séances'**
  String get lastTenSessions;

  /// No description provided for @noAttendanceYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de présence enregistrée.'**
  String get noAttendanceYet;

  /// No description provided for @commentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get commentsTitle;

  /// No description provided for @commentsVisibility.
  ///
  /// In fr, this message translates to:
  /// **'Visible par l\'élève et ses parents'**
  String get commentsVisibility;

  /// No description provided for @commentHint.
  ///
  /// In fr, this message translates to:
  /// **'Un mot pour l\'élève et ses parents…'**
  String get commentHint;

  /// No description provided for @privateNotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes privées'**
  String get privateNotesTitle;

  /// No description provided for @privateNotesVisibility.
  ///
  /// In fr, this message translates to:
  /// **'Visible par vous uniquement'**
  String get privateNotesVisibility;

  /// No description provided for @noPrivateNotes.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note privée.'**
  String get noPrivateNotes;

  /// No description provided for @noteHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre note…'**
  String get noteHint;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette note ?'**
  String get deleteNoteTitle;

  /// No description provided for @createPrivateLesson.
  ///
  /// In fr, this message translates to:
  /// **'Créer un cours particulier'**
  String get createPrivateLesson;

  /// No description provided for @privateLessonText.
  ///
  /// In fr, this message translates to:
  /// **'Un groupe pour {name} seul, dans la matière choisie.'**
  String privateLessonText(String name);

  /// No description provided for @privateLessonCreated.
  ///
  /// In fr, this message translates to:
  /// **'Cours particulier créé.'**
  String get privateLessonCreated;

  /// No description provided for @subject.
  ///
  /// In fr, this message translates to:
  /// **'Matière'**
  String get subject;

  /// No description provided for @chooseSubject.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une matière'**
  String get chooseSubject;

  /// No description provided for @groupName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 4ème année · Maths'**
  String get groupNameHint;

  /// No description provided for @groupFormSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous ajouterez les élèves et l\'horaire ensuite.'**
  String get groupFormSubtitle;

  /// No description provided for @editGroup.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le groupe'**
  String get editGroup;

  /// No description provided for @color.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get color;

  /// No description provided for @defaultMeetLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien Meet par défaut'**
  String get defaultMeetLink;

  /// No description provided for @meetLinkHint.
  ///
  /// In fr, this message translates to:
  /// **'https://meet.google.com/…'**
  String get meetLinkHint;

  /// No description provided for @meetLinkInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le lien doit commencer par https://'**
  String get meetLinkInvalid;

  /// No description provided for @addMembers.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des élèves'**
  String get addMembers;

  /// No description provided for @groupMembersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Élèves du groupe'**
  String get groupMembersTitle;

  /// No description provided for @usualSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaire habituel'**
  String get usualSchedule;

  /// No description provided for @scheduleNote.
  ///
  /// In fr, this message translates to:
  /// **'Séances créées jusqu\'au {date}. Une séance se modifie seule ou avec les suivantes.'**
  String scheduleNote(String date);

  /// No description provided for @noScheduleYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'horaire habituel. Planifiez une séance et cochez Répéter chaque semaine.'**
  String get noScheduleYet;

  /// No description provided for @noMeetLink.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lien. Les séances sont en présentiel.'**
  String get noMeetLink;

  /// No description provided for @archiveGroup.
  ///
  /// In fr, this message translates to:
  /// **'Archiver le groupe'**
  String get archiveGroup;

  /// No description provided for @archiveGroupText.
  ///
  /// In fr, this message translates to:
  /// **'Le groupe disparaît des listes. Ses séances passées restent dans l\'historique des élèves.'**
  String get archiveGroupText;

  /// No description provided for @groupArchived.
  ///
  /// In fr, this message translates to:
  /// **'Groupe archivé.'**
  String get groupArchived;

  /// No description provided for @noMembers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élève dans ce groupe.'**
  String get noMembers;

  /// No description provided for @chooseStudents.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les élèves'**
  String get chooseStudents;

  /// No description provided for @selectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sélectionnés'**
  String selectedCount(int count);

  /// No description provided for @saveMembers.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveMembers;

  /// No description provided for @viewDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get viewDay;

  /// No description provided for @viewWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get viewWeek;

  /// No description provided for @previous.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @allGroups.
  ///
  /// In fr, this message translates to:
  /// **'Tous les groupes'**
  String get allGroups;

  /// No description provided for @newSession.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle séance'**
  String get newSession;

  /// No description provided for @planningLegend.
  ///
  /// In fr, this message translates to:
  /// **'Atténuée : terminée · Barrée : annulée · Cliquez sur un créneau vide pour ajouter une séance'**
  String get planningLegend;

  /// No description provided for @emptyWeek.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance cette semaine.'**
  String get emptyWeek;

  /// No description provided for @emptyDay.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance ce jour-là.'**
  String get emptyDay;

  /// No description provided for @editSession.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la séance'**
  String get editSession;

  /// No description provided for @group.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get group;

  /// No description provided for @chooseGroup.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un groupe'**
  String get chooseGroup;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @startTime.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get endTime;

  /// No description provided for @mode.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get location;

  /// No description provided for @locationHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Salle 2'**
  String get locationHint;

  /// No description provided for @meetLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien visio'**
  String get meetLink;

  /// No description provided for @fromGroup.
  ///
  /// In fr, this message translates to:
  /// **'Du groupe'**
  String get fromGroup;

  /// No description provided for @repeatWeekly.
  ///
  /// In fr, this message translates to:
  /// **'Répéter chaque semaine'**
  String get repeatWeekly;

  /// No description provided for @repeatWeeklyHint.
  ///
  /// In fr, this message translates to:
  /// **'Chaque {weekday} jusqu\'au {date}'**
  String repeatWeeklyHint(String weekday, String date);

  /// No description provided for @repeatUntil.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'au'**
  String get repeatUntil;

  /// No description provided for @sessionsToCreate.
  ///
  /// In fr, this message translates to:
  /// **'Séances créées'**
  String get sessionsToCreate;

  /// No description provided for @createSessions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Créer} =1{Créer la séance} other{Créer {count} séances}}'**
  String createSessions(int count);

  /// No description provided for @overlapWarning.
  ///
  /// In fr, this message translates to:
  /// **'Chevauche une séance : {session}. Vous pouvez continuer.'**
  String overlapWarning(String session);

  /// No description provided for @prepNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de préparation'**
  String get prepNotes;

  /// No description provided for @prepNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous voulez revoir…'**
  String get prepNotesHint;

  /// No description provided for @timeRangeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'L\'heure de fin doit être après l\'heure de début.'**
  String get timeRangeInvalid;

  /// No description provided for @noGroupsYet.
  ///
  /// In fr, this message translates to:
  /// **'Créez d\'abord un groupe dans Élèves.'**
  String get noGroupsYet;

  /// No description provided for @sessionsCreated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance créée.} =1{Séance créée.} other{{count} séances créées.}}'**
  String sessionsCreated(int count);

  /// No description provided for @sessionUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Séance modifiée.'**
  String get sessionUpdated;

  /// No description provided for @startSession.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer la séance'**
  String get startSession;

  /// No description provided for @resumeSession.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la séance'**
  String get resumeSession;

  /// No description provided for @openMeet.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir Meet'**
  String get openMeet;

  /// No description provided for @everyWeekdayUntil.
  ///
  /// In fr, this message translates to:
  /// **'Chaque {weekday}, jusqu\'au {date}'**
  String everyWeekdayUntil(String weekday, String date);

  /// No description provided for @cancelSession.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la séance'**
  String get cancelSession;

  /// No description provided for @restoreSession.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir la séance'**
  String get restoreSession;

  /// No description provided for @cancelledBecause.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String cancelledBecause(String reason);

  /// No description provided for @seriesNote.
  ///
  /// In fr, this message translates to:
  /// **'Cette séance fait partie d\'une série.'**
  String get seriesNote;

  /// No description provided for @scopeOne.
  ///
  /// In fr, this message translates to:
  /// **'Cette séance uniquement'**
  String get scopeOne;

  /// No description provided for @scopeFollowing.
  ///
  /// In fr, this message translates to:
  /// **'Cette séance et les suivantes'**
  String get scopeFollowing;

  /// No description provided for @scopeFollowingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} jusqu\'au {date}'**
  String scopeFollowingCount(String count, String date);

  /// No description provided for @cancelReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get cancelReason;

  /// No description provided for @cancelReasonVisibility.
  ///
  /// In fr, this message translates to:
  /// **'affiché à l\'élève et à ses parents'**
  String get cancelReasonVisibility;

  /// No description provided for @cancelReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : examen au lycée'**
  String get cancelReasonHint;

  /// No description provided for @cancelVisibleNote.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves et leurs parents sont prévenus dans l\'application et voient le motif dans leur planning.'**
  String get cancelVisibleNote;

  /// No description provided for @sessionCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Séance annulée.'**
  String get sessionCancelled;

  /// No description provided for @sessionRestored.
  ///
  /// In fr, this message translates to:
  /// **'Séance rétablie.'**
  String get sessionRestored;

  /// No description provided for @editAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les présences'**
  String get editAttendance;

  /// No description provided for @inProgressFor.
  ///
  /// In fr, this message translates to:
  /// **'En cours · {minutes} min'**
  String inProgressFor(int minutes);

  /// No description provided for @endSession.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la séance'**
  String get endSession;

  /// No description provided for @tapToChange.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un élève pour changer'**
  String get tapToChange;

  /// No description provided for @contentOfDay.
  ///
  /// In fr, this message translates to:
  /// **'Contenu du jour'**
  String get contentOfDay;

  /// No description provided for @lastSessionOn.
  ///
  /// In fr, this message translates to:
  /// **'Dernière séance · {day}'**
  String lastSessionOn(String day);

  /// No description provided for @noPreviousNote.
  ///
  /// In fr, this message translates to:
  /// **'Pas de note sur la dernière séance.'**
  String get noPreviousNote;

  /// No description provided for @quickNote.
  ///
  /// In fr, this message translates to:
  /// **'Note rapide'**
  String get quickNote;

  /// No description provided for @quickNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui s\'est passé, à revoir la prochaine fois…'**
  String get quickNoteHint;

  /// No description provided for @noteSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrée'**
  String get noteSaved;

  /// No description provided for @noteSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get noteSaving;

  /// No description provided for @endSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la séance ?'**
  String get endSessionTitle;

  /// No description provided for @endSessionText.
  ///
  /// In fr, this message translates to:
  /// **'Présences enregistrées : {summary}.'**
  String endSessionText(String summary);

  /// No description provided for @sessionEnded.
  ///
  /// In fr, this message translates to:
  /// **'Séance terminée.'**
  String get sessionEnded;

  /// No description provided for @joinSession.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre la séance'**
  String get joinSession;

  /// No description provided for @childSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances de {name}'**
  String childSessions(String name);

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @cancelledCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune annulée} =1{1 annulée} other{{count} annulées}}'**
  String cancelledCount(int count);

  /// No description provided for @absencesThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune absence ce mois} =1{1 absence ce mois} other{{count} absences ce mois}}'**
  String absencesThisMonth(int count);

  /// No description provided for @emptyMyPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance dans les deux prochaines semaines.'**
  String get emptyMyPlanning;

  /// No description provided for @todayInDuration.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, dans {duration}'**
  String todayInDuration(String duration);

  /// No description provided for @homeSessionsToday.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance aujourd\'hui.} =1{1 séance aujourd\'hui.} other{{count} séances aujourd\'hui.}}'**
  String homeSessionsToday(int count);

  /// No description provided for @tomorrowSessions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Demain : aucune séance.} =1{Demain : 1 séance, à {time}.} other{Demain : {count} séances, la première à {time}.}}'**
  String tomorrowSessions(int count, String time);

  /// No description provided for @attendanceOf.
  ///
  /// In fr, this message translates to:
  /// **'présences {present} sur {total}'**
  String attendanceOf(int present, int total);

  /// No description provided for @childAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès de l\'élève'**
  String get childAccess;

  /// No description provided for @childAccessHint.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif. Les élèves du primaire n\'en ont souvent pas besoin : leurs parents suivent tout.'**
  String get childAccessHint;

  /// No description provided for @createChildAccess.
  ///
  /// In fr, this message translates to:
  /// **'Créer un accès'**
  String get createChildAccess;

  /// No description provided for @removeChildAccess.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'accès'**
  String get removeChildAccess;

  /// No description provided for @removeChildAccessText.
  ///
  /// In fr, this message translates to:
  /// **'{name} ne pourra plus se connecter. Ses parents continuent de tout suivre.'**
  String removeChildAccessText(String name);

  /// No description provided for @childAccessRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Accès retiré.'**
  String get childAccessRemoved;

  /// No description provided for @noChildAccess.
  ///
  /// In fr, this message translates to:
  /// **'sans accès, suivi par ses parents'**
  String get noChildAccess;

  /// No description provided for @newSubject.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle matière'**
  String get newSubject;

  /// No description provided for @subjectNameFr.
  ///
  /// In fr, this message translates to:
  /// **'Nom en français'**
  String get subjectNameFr;

  /// No description provided for @subjectNameAr.
  ///
  /// In fr, this message translates to:
  /// **'Nom en arabe'**
  String get subjectNameAr;

  /// No description provided for @subjectNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Mathématiques, Lecture, Éveil scientifique'**
  String get subjectNameHint;

  /// No description provided for @subjectNameArHint.
  ///
  /// In fr, this message translates to:
  /// **'S\'il est vide, le nom français est affiché.'**
  String get subjectNameArHint;

  /// No description provided for @subjectCreated.
  ///
  /// In fr, this message translates to:
  /// **'Matière créée.'**
  String get subjectCreated;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les matières que vous enseignez, vos niveaux et l\'année scolaire.'**
  String get settingsSubtitle;

  /// No description provided for @yourSubjects.
  ///
  /// In fr, this message translates to:
  /// **'Vos matières'**
  String get yourSubjects;

  /// No description provided for @subjectNoArabicName.
  ///
  /// In fr, this message translates to:
  /// **'Pas de nom arabe : le nom français est affiché'**
  String get subjectNoArabicName;

  /// No description provided for @subjectInUse.
  ///
  /// In fr, this message translates to:
  /// **'Utilisée par un groupe : elle ne peut pas être supprimée.'**
  String get subjectInUse;

  /// No description provided for @subjectDeleteRule.
  ///
  /// In fr, this message translates to:
  /// **'Une matière utilisée par un groupe ne peut pas être supprimée : changez d\'abord la matière du groupe.'**
  String get subjectDeleteRule;

  /// No description provided for @editSubject.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la matière'**
  String get editSubject;

  /// No description provided for @subjectUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Matière modifiée.'**
  String get subjectUpdated;

  /// No description provided for @deleteSubjectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name} ?'**
  String deleteSubjectTitle(String name);

  /// No description provided for @deleteSubjectText.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe ne l\'utilise. Cette suppression est définitive.'**
  String get deleteSubjectText;

  /// No description provided for @subjectDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Matière supprimée.'**
  String get subjectDeleted;

  /// No description provided for @levelsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveaux'**
  String get levelsTitle;

  /// No description provided for @primarySchool.
  ///
  /// In fr, this message translates to:
  /// **'Primaire'**
  String get primarySchool;

  /// No description provided for @levelsNote.
  ///
  /// In fr, this message translates to:
  /// **'Les six années du primaire tunisien, en français et en arabe.'**
  String get levelsNote;

  /// No description provided for @schoolYearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Année scolaire'**
  String get schoolYearTitle;

  /// No description provided for @schoolYearRange.
  ///
  /// In fr, this message translates to:
  /// **'du {start} au {end}'**
  String schoolYearRange(String start, String end);

  /// No description provided for @noSubjectsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune matière pour l\'instant. Créez la première.'**
  String get noSubjectsYet;

  /// No description provided for @loginIdentifierHint.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou numéro'**
  String get loginIdentifierHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get loginPasswordHint;

  /// No description provided for @notificationsUnread.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tout est lu} =1{1 non lue} other{{count} non lues}}'**
  String notificationsUnread(int count);

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllRead;

  /// No description provided for @notificationsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get notificationsToday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In fr, this message translates to:
  /// **'Plus tôt'**
  String get notificationsEarlier;

  /// No description provided for @notificationCancelled.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance annulée} =1{Séance annulée} other{{count} séances annulées}}'**
  String notificationCancelled(int count);

  /// No description provided for @notificationMoved.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance déplacée} =1{Séance déplacée} other{{count} séances déplacées}}'**
  String notificationMoved(int count);

  /// No description provided for @notificationRestored.
  ///
  /// In fr, this message translates to:
  /// **'Séance rétablie'**
  String get notificationRestored;

  /// No description provided for @fromDate.
  ///
  /// In fr, this message translates to:
  /// **'À partir du {date}'**
  String fromDate(String date);

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{À l\'instant} =1{Il y a 1 min} other{Il y a {count} min}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{À l\'instant} =1{Il y a 1 h} other{Il y a {count} h}}'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification pour le moment.'**
  String get noNotifications;

  /// No description provided for @noNotificationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez prévenu ici si une séance est annulée, déplacée ou rétablie.'**
  String get noNotificationsHint;

  /// No description provided for @familiesWillBeTold.
  ///
  /// In fr, this message translates to:
  /// **'Si la date ou l\'heure change, les élèves et les parents seront prévenus dans l\'application.'**
  String get familiesWillBeTold;

  /// No description provided for @modeInClass.
  ///
  /// In fr, this message translates to:
  /// **'En classe'**
  String get modeInClass;

  /// No description provided for @weekSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Plus de séance cette semaine.} =1{Cette semaine, il te reste 1 séance.} other{Cette semaine, il te reste {count} séances.}}'**
  String weekSummary(int count);

  /// No description provided for @whatsNew.
  ///
  /// In fr, this message translates to:
  /// **'Du nouveau'**
  String get whatsNew;

  /// No description provided for @myWeek.
  ///
  /// In fr, this message translates to:
  /// **'Ma semaine'**
  String get myWeek;

  /// No description provided for @seePlanning.
  ///
  /// In fr, this message translates to:
  /// **'Voir le planning'**
  String get seePlanning;

  /// No description provided for @legendSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance'**
  String get legendSession;

  /// No description provided for @nextWeekSessions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Pas de séance la semaine prochaine.} =1{La semaine prochaine : 1 séance.} other{La semaine prochaine : {count} séances.}}'**
  String nextWeekSessions(int count);

  /// No description provided for @nextWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine prochaine'**
  String get nextWeek;

  /// No description provided for @laterOn.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get laterOn;

  /// No description provided for @tomorrowWeekday.
  ///
  /// In fr, this message translates to:
  /// **'Demain, {weekday}'**
  String tomorrowWeekday(String weekday);

  /// No description provided for @newTime.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel horaire'**
  String get newTime;

  /// No description provided for @previousTime.
  ///
  /// In fr, this message translates to:
  /// **'Avant : {when}'**
  String previousTime(String when);

  /// No description provided for @dayAtTime.
  ///
  /// In fr, this message translates to:
  /// **'{day} à {time}'**
  String dayAtTime(String day, String time);

  /// No description provided for @joinOpensBefore.
  ///
  /// In fr, this message translates to:
  /// **'Le lien pour rejoindre apparaît 15 min avant.'**
  String get joinOpensBefore;

  /// No description provided for @noNotificationsHintStudent.
  ///
  /// In fr, this message translates to:
  /// **'Tu seras prévenu ici si une séance est annulée, déplacée ou rétablie.'**
  String get noNotificationsHintStudent;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @navTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Enseignants'**
  String get navTeachers;

  /// No description provided for @adminArea.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminArea;

  /// No description provided for @teachersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Chaque enseignant travaille dans son propre espace, avec ses élèves et leurs parents.'**
  String get teachersSubtitle;

  /// No description provided for @newTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel enseignant'**
  String get newTeacher;

  /// No description provided for @teachersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun enseignant} =1{1 enseignant} other{{count} enseignants}}'**
  String teachersCount(int count);

  /// No description provided for @activeAccounts.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun compte actif} =1{1 compte actif} other{{count} comptes actifs}}'**
  String activeAccounts(int count);

  /// No description provided for @statStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves suivis'**
  String get statStudents;

  /// No description provided for @statParents.
  ///
  /// In fr, this message translates to:
  /// **'Comptes parents'**
  String get statParents;

  /// No description provided for @statGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes en cours'**
  String get statGroups;

  /// No description provided for @allSpaces.
  ///
  /// In fr, this message translates to:
  /// **'Tous les espaces'**
  String get allSpaces;

  /// No description provided for @searchTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Nom, identifiant, téléphone'**
  String get searchTeachers;

  /// No description provided for @columnTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get columnTeacher;

  /// No description provided for @columnStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get columnStatus;

  /// No description provided for @columnStudents.
  ///
  /// In fr, this message translates to:
  /// **'Élèves'**
  String get columnStudents;

  /// No description provided for @columnLastLogin.
  ///
  /// In fr, this message translates to:
  /// **'Dernière connexion'**
  String get columnLastLogin;

  /// No description provided for @teacherActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get teacherActive;

  /// No description provided for @teacherTemporaryPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe temporaire'**
  String get teacherTemporaryPassword;

  /// No description provided for @teacherDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get teacherDisabled;

  /// No description provided for @lastLoginNever.
  ///
  /// In fr, this message translates to:
  /// **'Jamais connecté'**
  String get lastLoginNever;

  /// No description provided for @teacherActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get teacherActions;

  /// No description provided for @disableAccess.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver l\'accès'**
  String get disableAccess;

  /// No description provided for @enableAccess.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver l\'accès'**
  String get enableAccess;

  /// No description provided for @disableTeacherTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver l\'accès de {name} ?'**
  String disableTeacherTitle(String name);

  /// No description provided for @disableTeacherText.
  ///
  /// In fr, this message translates to:
  /// **'La connexion à ce compte sera bloquée. Ses élèves et leurs parents gardent leur accès. Rien n\'est supprimé : vous pourrez le réactiver.'**
  String get disableTeacherText;

  /// No description provided for @teacherDisabledNotice.
  ///
  /// In fr, this message translates to:
  /// **'Accès de {name} désactivé.'**
  String teacherDisabledNotice(String name);

  /// No description provided for @teacherEnabledNotice.
  ///
  /// In fr, this message translates to:
  /// **'Accès de {name} réactivé.'**
  String teacherEnabledNotice(String name);

  /// No description provided for @newTeacherSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un identifiant et un mot de passe temporaire sont créés pour la première connexion.'**
  String get newTeacherSubtitle;

  /// No description provided for @teacherUsernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour se connecter. Le téléphone sert aussi, s\'il est indiqué.'**
  String get teacherUsernameHint;

  /// No description provided for @usernameRule.
  ///
  /// In fr, this message translates to:
  /// **'3 caractères au moins : lettres sans accent, chiffres, point, tiret.'**
  String get usernameRule;

  /// No description provided for @createTeacherAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte'**
  String get createTeacherAccount;

  /// No description provided for @noTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enseignant pour le moment.'**
  String get noTeachers;

  /// No description provided for @noTeachersHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez le premier : un identifiant et un mot de passe temporaire lui sont donnés.'**
  String get noTeachersHint;

  /// No description provided for @teacherCredentialsNote.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe temporaire n\'est montré qu\'une fois. L\'enseignant choisit le sien à la première connexion. En cas d\'oubli : Actions, Réinitialiser le mot de passe.'**
  String get teacherCredentialsNote;

  /// No description provided for @studentFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Adam'**
  String get studentFirstNameHint;

  /// No description provided for @parentFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Mouna'**
  String get parentFirstNameHint;

  /// No description provided for @teacherFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Sonia'**
  String get teacherFirstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Gharbi'**
  String get lastNameHint;

  /// No description provided for @teacherLastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Ben Ali'**
  String get teacherLastNameHint;

  /// No description provided for @studentUsernameExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : adam.gharbi'**
  String get studentUsernameExample;

  /// No description provided for @teacherUsernameExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : sonia.benali'**
  String get teacherUsernameExample;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : nom@exemple.com'**
  String get emailHint;

  /// No description provided for @subjectNameArExample.
  ///
  /// In fr, this message translates to:
  /// **'مثال: الرياضيات'**
  String get subjectNameArExample;

  /// No description provided for @relationHint.
  ///
  /// In fr, this message translates to:
  /// **'Mère, père, tuteur'**
  String get relationHint;

  /// No description provided for @temporaryPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe reçu'**
  String get temporaryPasswordHint;

  /// No description provided for @currentPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Celui utilisé pour se connecter'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Facile à retenir, difficile à deviner'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Le même, une seconde fois'**
  String get confirmPasswordHint;

  /// No description provided for @contentsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos documents, rangés par matière, niveau et chapitre.'**
  String get contentsSubtitle;

  /// No description provided for @newChapter.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau chapitre'**
  String get newChapter;

  /// No description provided for @importDocument.
  ///
  /// In fr, this message translates to:
  /// **'Importer un document'**
  String get importDocument;

  /// No description provided for @importShort.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importShort;

  /// No description provided for @shareChapter.
  ///
  /// In fr, this message translates to:
  /// **'Partager le chapitre'**
  String get shareChapter;

  /// No description provided for @unfiled.
  ///
  /// In fr, this message translates to:
  /// **'Sans chapitre'**
  String get unfiled;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un titre'**
  String get searchTitle;

  /// No description provided for @tagAll.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette : toutes'**
  String get tagAll;

  /// No description provided for @tagFilter.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette : {tag}'**
  String tagFilter(String tag);

  /// No description provided for @statusAll.
  ///
  /// In fr, this message translates to:
  /// **'Statut : tous'**
  String get statusAll;

  /// No description provided for @statusFilter.
  ///
  /// In fr, this message translates to:
  /// **'Statut : {status}'**
  String statusFilter(String status);

  /// No description provided for @documentsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun document} =1{1 document} other{{count} documents}}'**
  String documentsCount(int count);

  /// No description provided for @pagesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune page} =1{1 page} other{{count} pages}}'**
  String pagesCount(int count);

  /// No description provided for @columnDocument.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get columnDocument;

  /// No description provided for @columnTag.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get columnTag;

  /// No description provided for @columnSharedWith.
  ///
  /// In fr, this message translates to:
  /// **'Partagé avec'**
  String get columnSharedWith;

  /// No description provided for @columnEdited.
  ///
  /// In fr, this message translates to:
  /// **'Modifié'**
  String get columnEdited;

  /// No description provided for @notShared.
  ///
  /// In fr, this message translates to:
  /// **'Non partagé'**
  String get notShared;

  /// No description provided for @tagSerie.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get tagSerie;

  /// No description provided for @tagCours.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get tagCours;

  /// No description provided for @tagCorrige.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé'**
  String get tagCorrige;

  /// No description provided for @tagAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get tagAutre;

  /// No description provided for @statusPublished.
  ///
  /// In fr, this message translates to:
  /// **'Publié'**
  String get statusPublished;

  /// No description provided for @statusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get statusDraft;

  /// No description provided for @kindPdf.
  ///
  /// In fr, this message translates to:
  /// **'PDF'**
  String get kindPdf;

  /// No description provided for @kindImage.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get kindImage;

  /// No description provided for @kindWord.
  ///
  /// In fr, this message translates to:
  /// **'Word'**
  String get kindWord;

  /// No description provided for @toDownload.
  ///
  /// In fr, this message translates to:
  /// **'à télécharger'**
  String get toDownload;

  /// No description provided for @sizeKb.
  ///
  /// In fr, this message translates to:
  /// **'{value} Ko'**
  String sizeKb(String value);

  /// No description provided for @sizeMb.
  ///
  /// In fr, this message translates to:
  /// **'{value} Mo'**
  String sizeMb(String value);

  /// No description provided for @actionOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get actionOpen;

  /// No description provided for @actionShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get actionShare;

  /// No description provided for @actionEditDetails.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les détails'**
  String get actionEditDetails;

  /// No description provided for @renameChapter.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le chapitre'**
  String get renameChapter;

  /// No description provided for @deleteChapter.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le chapitre'**
  String get deleteChapter;

  /// No description provided for @documentActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions sur le document'**
  String get documentActions;

  /// No description provided for @chapterActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions sur le chapitre'**
  String get chapterActions;

  /// No description provided for @archiveDocumentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archiver « {title} » ?'**
  String archiveDocumentTitle(String title);

  /// No description provided for @archiveDocumentText.
  ///
  /// In fr, this message translates to:
  /// **'Il disparaît de la bibliothèque et des onglets Cours. Rien n\'est supprimé.'**
  String get archiveDocumentText;

  /// No description provided for @deleteChapterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le chapitre « {title} » ?'**
  String deleteChapterTitle(String title);

  /// No description provided for @deleteChapterText.
  ///
  /// In fr, this message translates to:
  /// **'Ses documents restent, dans « Sans chapitre ». Le partage du chapitre s\'arrête.'**
  String get deleteChapterText;

  /// No description provided for @documentArchived.
  ///
  /// In fr, this message translates to:
  /// **'Document archivé.'**
  String get documentArchived;

  /// No description provided for @chapterDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre supprimé.'**
  String get chapterDeleted;

  /// No description provided for @documentUploaded.
  ///
  /// In fr, this message translates to:
  /// **'Document importé.'**
  String get documentUploaded;

  /// No description provided for @detailsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées.'**
  String get detailsSaved;

  /// No description provided for @shareSaved.
  ///
  /// In fr, this message translates to:
  /// **'Partage enregistré.'**
  String get shareSaved;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre bibliothèque est vide.'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Importez une série, une leçon ou une photo du tableau, puis partagez-la avec un groupe.'**
  String get libraryEmptyHint;

  /// No description provided for @chapterEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document dans ce chapitre.'**
  String get chapterEmpty;

  /// No description provided for @subjectEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document dans cette matière pour l\'instant.'**
  String get subjectEmpty;

  /// No description provided for @draftCannotShare.
  ///
  /// In fr, this message translates to:
  /// **'Un brouillon ne peut pas être partagé. Publiez-le d\'abord.'**
  String get draftCannotShare;

  /// No description provided for @importSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une classe entière d\'un coup, depuis Excel : les élèves, leurs parents et leurs accès.'**
  String get importSubtitle;

  /// No description provided for @editDetailsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre, rangement, étiquette et statut.'**
  String get editDetailsSubtitle;

  /// No description provided for @chooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get chooseFile;

  /// No description provided for @changeFile.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get changeFile;

  /// No description provided for @fileUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Format non accepté : choisissez un PDF, une photo JPG ou PNG, ou un fichier Word.'**
  String get fileUnsupported;

  /// No description provided for @fileTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier dépasse 20 Mo.'**
  String get fileTooLarge;

  /// No description provided for @fileEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier est vide.'**
  String get fileEmpty;

  /// No description provided for @fileRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un fichier.'**
  String get fileRequired;

  /// No description provided for @documentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get documentTitle;

  /// No description provided for @documentTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Série 2 : les fractions'**
  String get documentTitleHint;

  /// No description provided for @documentTitleHelper.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves voient ce titre.'**
  String get documentTitleHelper;

  /// No description provided for @chapter.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre'**
  String get chapter;

  /// No description provided for @tag.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette'**
  String get tag;

  /// No description provided for @shareWith.
  ///
  /// In fr, this message translates to:
  /// **'Partager avec'**
  String get shareWith;

  /// No description provided for @shareWithHint.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves de ces groupes le voient dans Cours. Vous pourrez partager plus tard.'**
  String get shareWithHint;

  /// No description provided for @keepDraft.
  ///
  /// In fr, this message translates to:
  /// **'Garder en brouillon'**
  String get keepDraft;

  /// No description provided for @keepDraftHint.
  ///
  /// In fr, this message translates to:
  /// **'Un brouillon n\'est jamais visible par les élèves.'**
  String get keepDraftHint;

  /// No description provided for @uploadProgress.
  ///
  /// In fr, this message translates to:
  /// **'Envoi : {percent} %'**
  String uploadProgress(int percent);

  /// No description provided for @chapterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du chapitre'**
  String get chapterTitle;

  /// No description provided for @chapterTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Les fractions'**
  String get chapterTitleHint;

  /// No description provided for @shareDocumentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager « {title} »'**
  String shareDocumentTitle(String title);

  /// No description provided for @shareChapterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager le chapitre « {title} »'**
  String shareChapterTitle(String title);

  /// No description provided for @shareSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves des groupes cochés le voient dans leur onglet Cours.'**
  String get shareSubtitle;

  /// No description provided for @shareChapterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tous ses documents publiés, et ceux ajoutés ensuite.'**
  String get shareChapterSubtitle;

  /// No description provided for @groupsOfLevel.
  ///
  /// In fr, this message translates to:
  /// **'Groupes de {level}'**
  String groupsOfLevel(String level);

  /// No description provided for @otherGroups.
  ///
  /// In fr, this message translates to:
  /// **'Autres groupes'**
  String get otherGroups;

  /// No description provided for @unshareNote.
  ///
  /// In fr, this message translates to:
  /// **'Décocher un groupe retire le document de son onglet Cours. Rien n\'est supprimé.'**
  String get unshareNote;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @pageOf.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} sur {count}'**
  String pageOf(int page, int count);

  /// No description provided for @previousPage.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get nextPage;

  /// No description provided for @zoomIn.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get zoomOut;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @detailFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get detailFile;

  /// No description provided for @wordNoPreview.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier Word ne s\'ouvre pas dans l\'application. Téléchargez-le pour le lire.'**
  String get wordNoPreview;

  /// No description provided for @downloadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le téléchargement n\'a pas pu démarrer.'**
  String get downloadFailed;

  /// No description provided for @pageNotShown.
  ///
  /// In fr, this message translates to:
  /// **'Cette page ne s\'affiche pas.'**
  String get pageNotShown;

  /// No description provided for @myCoursesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes cours'**
  String get myCoursesTitle;

  /// No description provided for @myCoursesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui a été partagé avec toi, par matière.'**
  String get myCoursesSubtitle;

  /// No description provided for @parentCoursesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cours pour {name}'**
  String parentCoursesTitle(String name);

  /// No description provided for @parentCoursesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les documents partagés avec {name}. Vous pouvez les ouvrir et les imprimer.'**
  String parentCoursesSubtitle(String name);

  /// No description provided for @allSubjects.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get allSubjects;

  /// No description provided for @newBadge.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get newBadge;

  /// No description provided for @coursEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'est encore partagé avec toi.'**
  String get coursEmpty;

  /// No description provided for @coursEmptyParent.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'est encore partagé avec {name}.'**
  String coursEmptyParent(String name);

  /// No description provided for @scanSheets.
  ///
  /// In fr, this message translates to:
  /// **'Scanner des feuilles'**
  String get scanSheets;

  /// No description provided for @scanSheetsHint.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs pages, un seul PDF'**
  String get scanSheetsHint;

  /// No description provided for @fileTypesShort.
  ///
  /// In fr, this message translates to:
  /// **'PDF, JPG, PNG, Word'**
  String get fileTypesShort;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la galerie'**
  String get fromGallery;

  /// No description provided for @addPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des photos'**
  String get addPhotos;

  /// No description provided for @scanHint.
  ///
  /// In fr, this message translates to:
  /// **'Posez la feuille à plat, bien éclairée. Appuyez sur une page pour la recadrer ou la pivoter, maintenez-la pour la déplacer.'**
  String get scanHint;

  /// No description provided for @scanColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get scanColor;

  /// No description provided for @scanBlackWhite.
  ///
  /// In fr, this message translates to:
  /// **'Noir et blanc'**
  String get scanBlackWhite;

  /// No description provided for @createPdf.
  ///
  /// In fr, this message translates to:
  /// **'Créer le PDF'**
  String get createPdf;

  /// No description provided for @scanEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prenez la première feuille en photo.'**
  String get scanEmptyTitle;

  /// No description provided for @scanEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Une photo par feuille. Vous pourrez recadrer, pivoter et changer l\'ordre.'**
  String get scanEmptyHint;

  /// No description provided for @scanPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation…'**
  String get scanPreparing;

  /// No description provided for @scanDiscardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner le scan ?'**
  String get scanDiscardTitle;

  /// No description provided for @scanDiscardText.
  ///
  /// In fr, this message translates to:
  /// **'Les photos prises ici seront perdues.'**
  String get scanDiscardText;

  /// No description provided for @scanDiscard.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get scanDiscard;

  /// No description provided for @rotate.
  ///
  /// In fr, this message translates to:
  /// **'Pivoter'**
  String get rotate;

  /// No description provided for @resetCrop.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get resetCrop;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @deletePage.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la page'**
  String get deletePage;

  /// No description provided for @cropHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser les coins sur les bords de la feuille.'**
  String get cropHint;

  /// No description provided for @scanFileName.
  ///
  /// In fr, this message translates to:
  /// **'Scan du {date}'**
  String scanFileName(String date);

  /// No description provided for @scanPhotoFailed.
  ///
  /// In fr, this message translates to:
  /// **'Une photo n\'a pas pu être lue.'**
  String get scanPhotoFailed;

  /// No description provided for @scanPdfFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le PDF n\'a pas pu être créé.'**
  String get scanPdfFailed;

  /// No description provided for @pageNumber.
  ///
  /// In fr, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// No description provided for @cropCorner.
  ///
  /// In fr, this message translates to:
  /// **'Coin de la feuille'**
  String get cropCorner;

  /// No description provided for @scanEmptyTitleComputer.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les photos de vos feuilles.'**
  String get scanEmptyTitleComputer;

  /// No description provided for @scanEmptyHintComputer.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez les photos déjà prises, une par feuille. Vous pourrez recadrer, pivoter et changer l\'ordre.'**
  String get scanEmptyHintComputer;

  /// No description provided for @homeworkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vos élèves ont à faire, et qui l\'a rendu.'**
  String get homeworkSubtitle;

  /// No description provided for @newHomework.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau devoir'**
  String get newHomework;

  /// No description provided for @homeworkOpen.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get homeworkOpen;

  /// No description provided for @homeworkDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get homeworkDone;

  /// No description provided for @groupAll.
  ///
  /// In fr, this message translates to:
  /// **'Groupe : tous'**
  String get groupAll;

  /// No description provided for @groupFilter.
  ///
  /// In fr, this message translates to:
  /// **'Groupe : {name}'**
  String groupFilter(String name);

  /// No description provided for @columnHomework.
  ///
  /// In fr, this message translates to:
  /// **'Devoir'**
  String get columnHomework;

  /// No description provided for @columnDueFor.
  ///
  /// In fr, this message translates to:
  /// **'Pour le'**
  String get columnDueFor;

  /// No description provided for @columnSent.
  ///
  /// In fr, this message translates to:
  /// **'Rendus'**
  String get columnSent;

  /// No description provided for @sentOf.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun rendu sur {total}} =1{1 rendu sur {total}} other{{count} rendus sur {total}}}'**
  String sentOf(int count, int total);

  /// No description provided for @missingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun manquant} =1{1 manquant} other{{count} manquants}}'**
  String missingCount(int count);

  /// No description provided for @nothingToSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Rien à rendre'**
  String get nothingToSubmit;

  /// No description provided for @toRead.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get toRead;

  /// No description provided for @dueToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, {time}'**
  String dueToday(String time);

  /// No description provided for @dueTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain, {time}'**
  String dueTomorrow(String time);

  /// No description provided for @dueOn.
  ///
  /// In fr, this message translates to:
  /// **'{date}, {time}'**
  String dueOn(String date, String time);

  /// No description provided for @inDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aujourd\'hui} =1{demain} other{dans {count} jours}}'**
  String inDays(int count);

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aujourd\'hui} =1{hier} other{il y a {count} jours}}'**
  String daysAgo(int count);

  /// No description provided for @homeworkInfo.
  ///
  /// In fr, this message translates to:
  /// **'Après la date limite, un devoir non rendu passe en « Manquant » tout seul. Les élèves et leurs parents voient chaque nouveau devoir dans leurs notifications.'**
  String get homeworkInfo;

  /// No description provided for @homeworkEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devoir en cours.'**
  String get homeworkEmpty;

  /// No description provided for @homeworkEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Donnez un document de vos Contenus à un groupe, avec une date limite.'**
  String get homeworkEmptyHint;

  /// No description provided for @homeworkDoneEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devoir terminé pour l\'instant.'**
  String get homeworkDoneEmpty;

  /// No description provided for @newHomeworkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un document de la bibliothèque, pour un groupe ou quelques élèves, avec une date limite.'**
  String get newHomeworkSubtitle;

  /// No description provided for @documentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get documentLabel;

  /// No description provided for @chooseDocument.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un document'**
  String get chooseDocument;

  /// No description provided for @noPublishedDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Importez d\'abord un document dans Contenus.'**
  String get noPublishedDocuments;

  /// No description provided for @homeworkTitleHelper.
  ///
  /// In fr, this message translates to:
  /// **'Pris du document. Les élèves voient ce titre.'**
  String get homeworkTitleHelper;

  /// No description provided for @forLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pour'**
  String get forLabel;

  /// No description provided for @forGroup.
  ///
  /// In fr, this message translates to:
  /// **'Un groupe'**
  String get forGroup;

  /// No description provided for @forStudents.
  ///
  /// In fr, this message translates to:
  /// **'Des élèves'**
  String get forStudents;

  /// No description provided for @pickStudentsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Cochez au moins un élève.'**
  String get pickStudentsRequired;

  /// No description provided for @deadlineDate.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get deadlineDate;

  /// No description provided for @deadlineTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get deadlineTime;

  /// No description provided for @deadlineInPast.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une date limite à venir.'**
  String get deadlineInPast;

  /// No description provided for @submissionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rendu'**
  String get submissionLabel;

  /// No description provided for @modeFile.
  ///
  /// In fr, this message translates to:
  /// **'Photos ou PDF'**
  String get modeFile;

  /// No description provided for @modeNone.
  ///
  /// In fr, this message translates to:
  /// **'Rien à rendre'**
  String get modeNone;

  /// No description provided for @modeFileHint.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves prennent leur cahier en photo : les pages deviennent un seul PDF.'**
  String get modeFileHint;

  /// No description provided for @modeNoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Un document à lire, sans statut.'**
  String get modeNoneHint;

  /// No description provided for @instructionsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Consignes'**
  String get instructionsLabel;

  /// No description provided for @instructionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Fais les exercices 1 à 3 sur ton cahier.'**
  String get instructionsHint;

  /// No description provided for @allowLate.
  ///
  /// In fr, this message translates to:
  /// **'Accepter les rendus en retard'**
  String get allowLate;

  /// No description provided for @allowLateHint.
  ///
  /// In fr, this message translates to:
  /// **'Ils sont marqués « Rendu en retard ».'**
  String get allowLateHint;

  /// No description provided for @giveHomework.
  ///
  /// In fr, this message translates to:
  /// **'Donner le devoir'**
  String get giveHomework;

  /// No description provided for @homeworkGiven.
  ///
  /// In fr, this message translates to:
  /// **'Devoir donné.'**
  String get homeworkGiven;

  /// No description provided for @giveAsHomework.
  ///
  /// In fr, this message translates to:
  /// **'Donner en devoir'**
  String get giveAsHomework;

  /// No description provided for @hwStatusTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get hwStatusTodo;

  /// No description provided for @hwStatusSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Rendu'**
  String get hwStatusSubmitted;

  /// No description provided for @hwStatusLate.
  ///
  /// In fr, this message translates to:
  /// **'Rendu en retard'**
  String get hwStatusLate;

  /// No description provided for @hwStatusMissing.
  ///
  /// In fr, this message translates to:
  /// **'Manquant'**
  String get hwStatusMissing;

  /// No description provided for @hwStatusCorrected.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé'**
  String get hwStatusCorrected;

  /// No description provided for @tileSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Rendus'**
  String get tileSubmitted;

  /// No description provided for @tileLate.
  ///
  /// In fr, this message translates to:
  /// **'Rendus en retard'**
  String get tileLate;

  /// No description provided for @tileMissing.
  ///
  /// In fr, this message translates to:
  /// **'Manquants'**
  String get tileMissing;

  /// No description provided for @tileTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get tileTodo;

  /// No description provided for @columnSentAt.
  ///
  /// In fr, this message translates to:
  /// **'Rendu le'**
  String get columnSentAt;

  /// No description provided for @viewWork.
  ///
  /// In fr, this message translates to:
  /// **'Voir le rendu'**
  String get viewWork;

  /// No description provided for @nothingReceived.
  ///
  /// In fr, this message translates to:
  /// **'Rien reçu'**
  String get nothingReceived;

  /// No description provided for @changeDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Changer la date'**
  String get changeDeadline;

  /// No description provided for @closeHomework.
  ///
  /// In fr, this message translates to:
  /// **'Clore'**
  String get closeHomework;

  /// No description provided for @closeHomeworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clore « {title} » ?'**
  String closeHomeworkTitle(String title);

  /// No description provided for @closeHomeworkText.
  ///
  /// In fr, this message translates to:
  /// **'Plus aucun travail ne pourra être envoyé. Ce qui a été envoyé reste.'**
  String get closeHomeworkText;

  /// No description provided for @homeworkClosed.
  ///
  /// In fr, this message translates to:
  /// **'Devoir clos.'**
  String get homeworkClosed;

  /// No description provided for @deadlineChanged.
  ///
  /// In fr, this message translates to:
  /// **'Date limite changée.'**
  String get deadlineChanged;

  /// No description provided for @lateAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Retard accepté'**
  String get lateAccepted;

  /// No description provided for @closedChip.
  ///
  /// In fr, this message translates to:
  /// **'Clos'**
  String get closedChip;

  /// No description provided for @dueFor.
  ///
  /// In fr, this message translates to:
  /// **'Pour le {when}'**
  String dueFor(String when);

  /// No description provided for @newDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle date limite'**
  String get newDeadline;

  /// No description provided for @myHomeworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes devoirs'**
  String get myHomeworkTitle;

  /// No description provided for @myHomeworkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que tu as à faire, le plus pressé en premier.'**
  String get myHomeworkSubtitle;

  /// No description provided for @parentHomeworkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs pour {name}'**
  String parentHomeworkTitle(String name);

  /// No description provided for @parentHomeworkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que {name} a à faire, et ce qui a été envoyé.'**
  String parentHomeworkSubtitle(String name);

  /// No description provided for @sectionTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get sectionTodo;

  /// No description provided for @sectionDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get sectionDone;

  /// No description provided for @dueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pour {when}'**
  String dueLabel(String when);

  /// No description provided for @sentOn.
  ///
  /// In fr, this message translates to:
  /// **'Rendu {when}'**
  String sentOn(String when);

  /// No description provided for @readBefore.
  ///
  /// In fr, this message translates to:
  /// **'À lire avant {when}'**
  String readBefore(String when);

  /// No description provided for @myHomeworkEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devoir pour l\'instant.'**
  String get myHomeworkEmpty;

  /// No description provided for @parentHomeworkEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devoir pour {name} pour l\'instant.'**
  String parentHomeworkEmpty(String name);

  /// No description provided for @yourWork.
  ///
  /// In fr, this message translates to:
  /// **'Ton travail'**
  String get yourWork;

  /// No description provided for @childWork.
  ///
  /// In fr, this message translates to:
  /// **'Le travail de {name}'**
  String childWork(String name);

  /// No description provided for @workPhotosHint.
  ///
  /// In fr, this message translates to:
  /// **'Une photo par page du cahier : elles deviennent un seul PDF.'**
  String get workPhotosHint;

  /// No description provided for @takeMyWork.
  ///
  /// In fr, this message translates to:
  /// **'Prendre mon travail en photo'**
  String get takeMyWork;

  /// No description provided for @takeTheWork.
  ///
  /// In fr, this message translates to:
  /// **'Prendre le travail en photo'**
  String get takeTheWork;

  /// No description provided for @orChooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Ou choisir un fichier'**
  String get orChooseFile;

  /// No description provided for @replaceMyWork.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer mon travail'**
  String get replaceMyWork;

  /// No description provided for @replaceTheWork.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer le travail'**
  String get replaceTheWork;

  /// No description provided for @workSent.
  ///
  /// In fr, this message translates to:
  /// **'C\'est envoyé !'**
  String get workSent;

  /// No description provided for @myWork.
  ///
  /// In fr, this message translates to:
  /// **'Mon travail'**
  String get myWork;

  /// No description provided for @sentWork.
  ///
  /// In fr, this message translates to:
  /// **'Travail envoyé'**
  String get sentWork;

  /// No description provided for @canReplaceUntilTu.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux le remplacer jusqu\'à {when}.'**
  String canReplaceUntilTu(String when);

  /// No description provided for @canReplaceUntil.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez le remplacer jusqu\'à {when}.'**
  String canReplaceUntil(String when);

  /// No description provided for @deadlinePassedNotice.
  ///
  /// In fr, this message translates to:
  /// **'La date limite est passée : le devoir ne peut plus être envoyé.'**
  String get deadlinePassedNotice;

  /// No description provided for @closedNotice.
  ///
  /// In fr, this message translates to:
  /// **'Ce devoir est clos.'**
  String get closedNotice;

  /// No description provided for @readOnlyNotice.
  ///
  /// In fr, this message translates to:
  /// **'Rien à rendre : il suffit de lire le document.'**
  String get readOnlyNotice;

  /// No description provided for @missingNotice.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'a été envoyé avant la date limite.'**
  String get missingNotice;

  /// No description provided for @lateSentNotice.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé après la date limite.'**
  String get lateSentNotice;

  /// No description provided for @workSentNotice.
  ///
  /// In fr, this message translates to:
  /// **'Travail envoyé.'**
  String get workSentNotice;

  /// No description provided for @notificationHomework.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau devoir'**
  String get notificationHomework;

  /// No description provided for @workFileUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Format non accepté : envoyez un PDF ou une photo JPG ou PNG.'**
  String get workFileUnsupported;

  /// No description provided for @submissionInfo.
  ///
  /// In fr, this message translates to:
  /// **'« Voir le rendu » ouvre le travail envoyé. La correction et la note sur 20 arrivent avec une prochaine version.'**
  String get submissionInfo;

  /// No description provided for @parentSendsNotice.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez photographier le travail de {name} et l\'envoyer ici, à sa place.'**
  String parentSendsNotice(String name);

  /// No description provided for @notificationCorrected.
  ///
  /// In fr, this message translates to:
  /// **'Devoir corrigé'**
  String get notificationCorrected;

  /// No description provided for @correctedSeeGrade.
  ///
  /// In fr, this message translates to:
  /// **'La note est arrivée · {group}'**
  String correctedSeeGrade(String group);

  /// No description provided for @subjectAllFilter.
  ///
  /// In fr, this message translates to:
  /// **'Matière : toutes'**
  String get subjectAllFilter;

  /// No description provided for @subjectFilter.
  ///
  /// In fr, this message translates to:
  /// **'Matière : {name}'**
  String subjectFilter(String name);

  /// No description provided for @toCorrectCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien à corriger} =1{1 à corriger} other{{count} à corriger}}'**
  String toCorrectCount(int count);

  /// No description provided for @deadlineWas.
  ///
  /// In fr, this message translates to:
  /// **'date limite {when}'**
  String deadlineWas(String when);

  /// No description provided for @correctAction.
  ///
  /// In fr, this message translates to:
  /// **'Corriger'**
  String get correctAction;

  /// No description provided for @correctCount.
  ///
  /// In fr, this message translates to:
  /// **'Corriger ({count})'**
  String correctCount(int count);

  /// No description provided for @toCorrectInfo.
  ///
  /// In fr, this message translates to:
  /// **'Chaque travail envoyé arrive ici, le plus ancien en premier. La note et le commentaire sont visibles par l\'élève et ses parents dès l\'enregistrement.'**
  String get toCorrectInfo;

  /// No description provided for @toCorrectEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Les travaux envoyés par vos élèves arriveront ici.'**
  String get toCorrectEmptyHint;

  /// No description provided for @copyOf.
  ///
  /// In fr, this message translates to:
  /// **'Copie {index} sur {count}'**
  String copyOf(int index, int count);

  /// No description provided for @previousCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copie précédente'**
  String get previousCopy;

  /// No description provided for @nextCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copie suivante'**
  String get nextCopy;

  /// No description provided for @scoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get scoreLabel;

  /// No description provided for @scoreHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 14,5'**
  String get scoreHint;

  /// No description provided for @scoreHelper.
  ///
  /// In fr, this message translates to:
  /// **'Un nombre de 0 à {max}, demi-points acceptés : 14,5.'**
  String scoreHelper(int max);

  /// No description provided for @scoreInvalid.
  ///
  /// In fr, this message translates to:
  /// **'La note va de 0 à {max}, par demi-points.'**
  String scoreInvalid(int max);

  /// No description provided for @commentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get commentLabel;

  /// No description provided for @commentSuffix.
  ///
  /// In fr, this message translates to:
  /// **'facultatif · visible par l\'élève et ses parents'**
  String get commentSuffix;

  /// No description provided for @correctionCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Bon travail, revois la simplification des fractions.'**
  String get correctionCommentHint;

  /// No description provided for @phraseVeryGood.
  ///
  /// In fr, this message translates to:
  /// **'Très bien !'**
  String get phraseVeryGood;

  /// No description provided for @phraseGoodWork.
  ///
  /// In fr, this message translates to:
  /// **'Bon travail'**
  String get phraseGoodWork;

  /// No description provided for @phraseReviewLesson.
  ///
  /// In fr, this message translates to:
  /// **'Revois la leçon'**
  String get phraseReviewLesson;

  /// No description provided for @phraseHandwriting.
  ///
  /// In fr, this message translates to:
  /// **'Soigne l\'écriture'**
  String get phraseHandwriting;

  /// No description provided for @correctedCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copie corrigée'**
  String get correctedCopy;

  /// No description provided for @takeCorrectedPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre en photo'**
  String get takeCorrectedPhoto;

  /// No description provided for @removeCopy.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeCopy;

  /// No description provided for @saveAndNext.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et suivant'**
  String get saveAndNext;

  /// No description provided for @nextCopyName.
  ///
  /// In fr, this message translates to:
  /// **'Copie suivante : {name}'**
  String nextCopyName(String name);

  /// No description provided for @lastCopy.
  ///
  /// In fr, this message translates to:
  /// **'C\'est la dernière copie à corriger de ce devoir.'**
  String get lastCopy;

  /// No description provided for @correctionSaved.
  ///
  /// In fr, this message translates to:
  /// **'Correction enregistrée.'**
  String get correctionSaved;

  /// No description provided for @allCorrected.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les copies de ce devoir sont corrigées.'**
  String get allCorrected;

  /// No description provided for @noWorkPane.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'a été envoyé. Vous pouvez noter une copie rendue sur papier.'**
  String get noWorkPane;

  /// No description provided for @columnScore.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get columnScore;

  /// No description provided for @viewCorrection.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get viewCorrection;

  /// No description provided for @gradeAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Noter'**
  String get gradeAnyway;

  /// No description provided for @tileCorrected.
  ///
  /// In fr, this message translates to:
  /// **'Corrigés'**
  String get tileCorrected;

  /// No description provided for @averageOutOf20.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne {value} / 20'**
  String averageOutOf20(String value);

  /// No description provided for @gradeAnywayInfo.
  ///
  /// In fr, this message translates to:
  /// **'« Noter » un élève sans rendu : une copie rendue sur papier, par exemple. Un devoir sans note ne compte jamais comme 0 dans la moyenne.'**
  String get gradeAnywayInfo;

  /// No description provided for @yourGrade.
  ///
  /// In fr, this message translates to:
  /// **'Ta note'**
  String get yourGrade;

  /// No description provided for @childGrade.
  ///
  /// In fr, this message translates to:
  /// **'La note de {name}'**
  String childGrade(String name);

  /// No description provided for @correctedOn.
  ///
  /// In fr, this message translates to:
  /// **'Corrigé {when}'**
  String correctedOn(String when);

  /// No description provided for @myResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes résultats'**
  String get myResultsTitle;

  /// No description provided for @myResultsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tes notes et ton travail, matière par matière.'**
  String get myResultsSubtitle;

  /// No description provided for @parentResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résultats de {name}'**
  String parentResultsTitle(String name);

  /// No description provided for @parentResultsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les notes et le travail de {name}, matière par matière.'**
  String parentResultsSubtitle(String name);

  /// No description provided for @averageOfGrades.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune note} =1{Une seule note} other{Moyenne de {count} notes}}'**
  String averageOfGrades(int count);

  /// No description provided for @trendUp.
  ///
  /// In fr, this message translates to:
  /// **'En progrès'**
  String get trendUp;

  /// No description provided for @trendDown.
  ///
  /// In fr, this message translates to:
  /// **'En baisse'**
  String get trendDown;

  /// No description provided for @trendStable.
  ///
  /// In fr, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @countOf.
  ///
  /// In fr, this message translates to:
  /// **'{count} sur {total}'**
  String countOf(int count, int total);

  /// No description provided for @homeworkSentLabel.
  ///
  /// In fr, this message translates to:
  /// **'devoirs rendus'**
  String get homeworkSentLabel;

  /// No description provided for @attendanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'présence'**
  String get attendanceLabel;

  /// No description provided for @gradesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get gradesTitle;

  /// No description provided for @resultsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de résultat : tes notes arriveront ici.'**
  String get resultsEmpty;

  /// No description provided for @resultsEmptyParent.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de résultat pour {name}.'**
  String resultsEmptyParent(String name);

  /// No description provided for @missingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Manquant : {title}'**
  String missingTitle(String title);

  /// No description provided for @seeResults.
  ///
  /// In fr, this message translates to:
  /// **'Voir les résultats'**
  String get seeResults;

  /// No description provided for @evaluationsTab.
  ///
  /// In fr, this message translates to:
  /// **'Évaluations'**
  String get evaluationsTab;

  /// No description provided for @newEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle évaluation'**
  String get newEvaluation;

  /// No description provided for @newEvaluationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un contrôle fait en classe, sur papier : vous saisissez les notes du groupe ensuite.'**
  String get newEvaluationSubtitle;

  /// No description provided for @editEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'évaluation'**
  String get editEvaluation;

  /// No description provided for @evaluationTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Évaluation : la multiplication'**
  String get evaluationTitleHint;

  /// No description provided for @evaluationTitleHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les élèves et les parents voient ce titre avec la note.'**
  String get evaluationTitleHelp;

  /// No description provided for @notedOn.
  ///
  /// In fr, this message translates to:
  /// **'Noté sur'**
  String get notedOn;

  /// No description provided for @scaleOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get scaleOther;

  /// No description provided for @scaleOtherLabel.
  ///
  /// In fr, this message translates to:
  /// **'Barème'**
  String get scaleOtherLabel;

  /// No description provided for @scaleOtherHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 40'**
  String get scaleOtherHint;

  /// No description provided for @scaleInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entre 1 et 100.'**
  String get scaleInvalid;

  /// No description provided for @evaluationScaleNote.
  ///
  /// In fr, this message translates to:
  /// **'La note compte dans la moyenne de la matière comme celle d\'un devoir. Une note sur 10 est ramenée sur 20 dans la moyenne.'**
  String get evaluationScaleNote;

  /// No description provided for @createAndGrade.
  ///
  /// In fr, this message translates to:
  /// **'Créer et saisir les notes'**
  String get createAndGrade;

  /// No description provided for @noChapter.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chapitre'**
  String get noChapter;

  /// No description provided for @gradesTyped.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune note sur {total}} =1{1 note sur {total}} other{{count} notes sur {total}}}'**
  String gradesTyped(int count, int total);

  /// No description provided for @gradesToType.
  ///
  /// In fr, this message translates to:
  /// **'Notes à saisir'**
  String get gradesToType;

  /// No description provided for @gradesDone.
  ///
  /// In fr, this message translates to:
  /// **'Notes saisies'**
  String get gradesDone;

  /// No description provided for @groupAverage.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne du groupe'**
  String get groupAverage;

  /// No description provided for @absentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get absentLabel;

  /// No description provided for @toType.
  ///
  /// In fr, this message translates to:
  /// **'À saisir'**
  String get toType;

  /// No description provided for @columnAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get columnAbsent;

  /// No description provided for @columnComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get columnComment;

  /// No description provided for @commentForPupilHint.
  ///
  /// In fr, this message translates to:
  /// **'Un mot pour l\'élève (facultatif)'**
  String get commentForPupilHint;

  /// No description provided for @saveGrades.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les notes'**
  String get saveGrades;

  /// No description provided for @gradesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Notes enregistrées.'**
  String get gradesSaved;

  /// No description provided for @scoreTooHigh.
  ///
  /// In fr, this message translates to:
  /// **'Au plus {max}.'**
  String scoreTooHigh(String max);

  /// No description provided for @scoreHalfPoints.
  ///
  /// In fr, this message translates to:
  /// **'Une note par demi-points : 14 ou 14,5.'**
  String get scoreHalfPoints;

  /// No description provided for @keyboardHint.
  ///
  /// In fr, this message translates to:
  /// **'Tab passe à l\'élève suivant, Maj + Tab revient, Entrée enregistre. Les demi-points s\'écrivent 11,5.'**
  String get keyboardHint;

  /// No description provided for @absentNeverZero.
  ///
  /// In fr, this message translates to:
  /// **'« Absent » ne compte jamais comme 0. À l\'enregistrement, les élèves et leurs parents voient leur note et le commentaire.'**
  String get absentNeverZero;

  /// No description provided for @outOf.
  ///
  /// In fr, this message translates to:
  /// **'Sur {max}'**
  String outOf(String max);

  /// No description provided for @unsavedGradesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter sans enregistrer ?'**
  String get unsavedGradesTitle;

  /// No description provided for @unsavedGradesText.
  ///
  /// In fr, this message translates to:
  /// **'Les notes tapées depuis le dernier enregistrement seront perdues.'**
  String get unsavedGradesText;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get leaveWithoutSaving;

  /// No description provided for @noEvaluations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune évaluation pour le moment.'**
  String get noEvaluations;

  /// No description provided for @noEvaluationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Un contrôle sur papier ? Créez-le ici et saisissez les notes du groupe au clavier.'**
  String get noEvaluationsHint;

  /// No description provided for @gradeKindEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation'**
  String get gradeKindEvaluation;

  /// No description provided for @gradeKindHomework.
  ///
  /// In fr, this message translates to:
  /// **'Devoir'**
  String get gradeKindHomework;

  /// No description provided for @notificationEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle note'**
  String get notificationEvaluation;

  /// No description provided for @evaluationSeeGrade.
  ///
  /// In fr, this message translates to:
  /// **'Une note est arrivée en {group}.'**
  String evaluationSeeGrade(String group);

  /// No description provided for @gradesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune note} =1{1 note} other{{count} notes}}'**
  String gradesCount(int count);

  /// No description provided for @dayContentEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document partagé avec ce groupe pour l\'instant.'**
  String get dayContentEmpty;

  /// No description provided for @notificationWorkSent.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun travail rendu} =1{1 travail rendu} other{{count} travaux rendus}}'**
  String notificationWorkSent(int count);

  /// No description provided for @notificationDeadlinePassed.
  ///
  /// In fr, this message translates to:
  /// **'Date limite passée'**
  String get notificationDeadlinePassed;

  /// No description provided for @workLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get workLate;

  /// No description provided for @everyoneSent.
  ///
  /// In fr, this message translates to:
  /// **'Tout le monde a rendu'**
  String get everyoneSent;

  /// No description provided for @missingPupils.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun manquant} =1{1 manquant : {names}} other{{count} manquants : {names}}}'**
  String missingPupils(int count, String names);

  /// No description provided for @namesAnd.
  ///
  /// In fr, this message translates to:
  /// **'{first} et {last}'**
  String namesAnd(String first, String last);

  /// No description provided for @namesAndOthers.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{{names}} =1{{names} et 1 autre} other{{names} et {count} autres}}'**
  String namesAndOthers(int count, String names);

  /// No description provided for @actionSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get actionSee;

  /// No description provided for @noNotificationsTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Rien de nouveau pour le moment.'**
  String get noNotificationsTeacher;

  /// No description provided for @noNotificationsHintTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez prévenue ici quand un élève rend un travail ou quand une date limite passe.'**
  String get noNotificationsHintTeacher;

  /// No description provided for @quickEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation'**
  String get quickEvaluation;

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer des élèves'**
  String get importTitle;

  /// No description provided for @importReadLines.
  ///
  /// In fr, this message translates to:
  /// **'{file} · {count, plural, =0{aucune ligne lue} =1{1 ligne lue} other{{count} lignes lues}}. Vérifiez avant de créer les élèves.'**
  String importReadLines(String file, int count);

  /// No description provided for @importStepFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get importStepFile;

  /// No description provided for @importStepCheck.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get importStepCheck;

  /// No description provided for @importStepAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants'**
  String get importStepAccounts;

  /// No description provided for @importStepOf.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur 3 · {name}'**
  String importStepOf(int step, String name);

  /// No description provided for @importChooseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre fichier'**
  String get importChooseTitle;

  /// No description provided for @importChooseHint.
  ///
  /// In fr, this message translates to:
  /// **'Excel (.xlsx) ou CSV, 300 lignes au plus. Rien n\'est créé avant la vérification.'**
  String get importChooseHint;

  /// No description provided for @importReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du fichier…'**
  String get importReading;

  /// No description provided for @importTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le modèle'**
  String get importTemplate;

  /// No description provided for @importColumnsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les colonnes attendues'**
  String get importColumnsTitle;

  /// No description provided for @importColumnsHint.
  ///
  /// In fr, this message translates to:
  /// **'Une ligne par élève. Les noms de colonnes peuvent être en français ou en arabe. * obligatoire.'**
  String get importColumnsHint;

  /// No description provided for @importColFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get importColFirstName;

  /// No description provided for @importColLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get importColLastName;

  /// No description provided for @importColParentFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom du parent'**
  String get importColParentFirstName;

  /// No description provided for @importColParentLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du parent'**
  String get importColParentLastName;

  /// No description provided for @importColParentPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone du parent'**
  String get importColParentPhone;

  /// No description provided for @importTipSiblings.
  ///
  /// In fr, this message translates to:
  /// **'Un parent qui a plusieurs enfants : le même téléphone sur chaque ligne, un seul accès est créé.'**
  String get importTipSiblings;

  /// No description provided for @importTipNoParent.
  ///
  /// In fr, this message translates to:
  /// **'Sans parent, l\'élève est ajouté quand même ; vous ouvrirez un accès plus tard depuis sa fiche.'**
  String get importTipNoParent;

  /// No description provided for @importForAll.
  ///
  /// In fr, this message translates to:
  /// **'Pour tous les élèves du fichier'**
  String get importForAll;

  /// No description provided for @importGroup.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au groupe'**
  String get importGroup;

  /// No description provided for @importNoGroup.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe'**
  String get importNoGroup;

  /// No description provided for @importGroupHelp.
  ///
  /// In fr, this message translates to:
  /// **'La colonne « Groupe » du fichier compte aussi.'**
  String get importGroupHelp;

  /// No description provided for @importLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau quand la colonne est vide'**
  String get importLevel;

  /// No description provided for @importCreateLogins.
  ///
  /// In fr, this message translates to:
  /// **'Créer aussi l\'accès des élèves'**
  String get importCreateLogins;

  /// No description provided for @importCreateLoginsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, seuls les parents reçoivent un accès (avec leur téléphone). Vous pourrez ouvrir celui d\'un élève depuis sa fiche.'**
  String get importCreateLoginsHelp;

  /// No description provided for @importReadyCount.
  ///
  /// In fr, this message translates to:
  /// **'Prêts à importer'**
  String get importReadyCount;

  /// No description provided for @importKnownCount.
  ///
  /// In fr, this message translates to:
  /// **'Parent déjà inscrit, lié'**
  String get importKnownCount;

  /// No description provided for @importExistsCount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit, ignoré'**
  String get importExistsCount;

  /// No description provided for @importErrorCount.
  ///
  /// In fr, this message translates to:
  /// **'À corriger dans le fichier'**
  String get importErrorCount;

  /// No description provided for @importColumnLine.
  ///
  /// In fr, this message translates to:
  /// **'Ligne'**
  String get importColumnLine;

  /// No description provided for @importColumnParent.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get importColumnParent;

  /// No description provided for @importColumnState.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get importColumnState;

  /// No description provided for @importStateReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get importStateReady;

  /// No description provided for @importStateKnown.
  ///
  /// In fr, this message translates to:
  /// **'Parent déjà inscrit'**
  String get importStateKnown;

  /// No description provided for @importStateExists.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit'**
  String get importStateExists;

  /// No description provided for @importStateError.
  ///
  /// In fr, this message translates to:
  /// **'À corriger'**
  String get importStateError;

  /// No description provided for @importKnownNote.
  ///
  /// In fr, this message translates to:
  /// **'{parent} a déjà un accès : {child} rejoint ses enfants.'**
  String importKnownNote(String parent, String child);

  /// No description provided for @importExistsNote.
  ///
  /// In fr, this message translates to:
  /// **'{name} est déjà dans vos élèves : cochez la ligne pour l\'ajouter quand même.'**
  String importExistsNote(String name);

  /// No description provided for @importSameParentNote.
  ///
  /// In fr, this message translates to:
  /// **'Même parent que la ligne {line} : un seul accès.'**
  String importSameParentNote(int line);

  /// No description provided for @importProblemFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom manquant.'**
  String get importProblemFirstName;

  /// No description provided for @importProblemLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom manquant.'**
  String get importProblemLastName;

  /// No description provided for @importProblemLevelMissing.
  ///
  /// In fr, this message translates to:
  /// **'Niveau manquant : choisissez-en un pour tout le fichier.'**
  String get importProblemLevelMissing;

  /// No description provided for @importProblemLevelUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Niveau inconnu : « {text} ». De la 1ère à la 6ème année.'**
  String importProblemLevelUnknown(String text);

  /// No description provided for @importProblemGroupUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Groupe inconnu : « {text} ».'**
  String importProblemGroupUnknown(String text);

  /// No description provided for @importProblemPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone de l\'élève : 8 chiffres.'**
  String get importProblemPhoneInvalid;

  /// No description provided for @importProblemPhoneTaken.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone de l\'élève est celui d\'un autre compte.'**
  String get importProblemPhoneTaken;

  /// No description provided for @importProblemParentPhoneMissing.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone du parent manquant : c\'est son identifiant.'**
  String get importProblemParentPhoneMissing;

  /// No description provided for @importProblemParentPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone du parent : 8 chiffres.'**
  String get importProblemParentPhoneInvalid;

  /// No description provided for @importProblemParentPhoneTaken.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone du parent est celui d\'un autre compte.'**
  String get importProblemParentPhoneTaken;

  /// No description provided for @importProblemParentName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom et nom du parent manquants.'**
  String get importProblemParentName;

  /// No description provided for @importProblemDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Même élève que la ligne {line}.'**
  String importProblemDuplicate(int line);

  /// No description provided for @importErrorsNote.
  ///
  /// In fr, this message translates to:
  /// **'Les lignes « À corriger » ne sont pas importées : corrigez-les dans votre fichier puis choisissez-le à nouveau, ou importez les autres maintenant et ajoutez ces élèves plus tard.'**
  String get importErrorsNote;

  /// No description provided for @importSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élève coché.} =1{1 élève sera ajouté} other{{count} élèves seront ajoutés}}'**
  String importSummary(int count);

  /// No description provided for @importSummaryParents.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{.} =1{, avec 1 nouvel accès parent.} other{, avec {count} nouveaux accès parents.}}'**
  String importSummaryParents(int count);

  /// No description provided for @importAnotherFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un autre fichier'**
  String get importAnotherFile;

  /// No description provided for @importAction.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Importer} =1{Importer 1 élève} other{Importer {count} élèves}}'**
  String importAction(int count);

  /// No description provided for @importDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élève ajouté} =1{1 élève ajouté} other{{count} élèves ajoutés}}'**
  String importDoneTitle(int count);

  /// No description provided for @importAddedTo.
  ///
  /// In fr, this message translates to:
  /// **'{title} à {group}'**
  String importAddedTo(String title, String group);

  /// No description provided for @importDoneParents.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun nouvel accès parent.} =1{1 nouvel accès parent.} other{{count} nouveaux accès parents.}}'**
  String importDoneParents(int count);

  /// No description provided for @importDoneLinked.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{} =1{ 1 enfant a rejoint un parent déjà inscrit.} other{ {count} enfants ont rejoint un parent déjà inscrit.}}'**
  String importDoneLinked(int count);

  /// No description provided for @importCopyAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout copier'**
  String get importCopyAll;

  /// No description provided for @importPrint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get importPrint;

  /// No description provided for @importPrintNote.
  ///
  /// In fr, this message translates to:
  /// **'Chacun choisit son propre mot de passe à la première connexion. « Imprimer » prépare une carte par famille à découper et à donner en classe.'**
  String get importPrintNote;

  /// No description provided for @importNoAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun nouvel accès à donner : les enfants ont rejoint des parents déjà inscrits ou n\'ont pas de parent.'**
  String get importNoAccounts;

  /// No description provided for @importAgain.
  ///
  /// In fr, this message translates to:
  /// **'Importer un autre fichier'**
  String get importAgain;

  /// No description provided for @importSeeStudents.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes élèves'**
  String get importSeeStudents;

  /// No description provided for @printCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès de {name}'**
  String printCardTitle(String name);

  /// No description provided for @printCardHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez NG Class, entrez l\'identifiant et ce mot de passe, puis choisissez le vôtre.'**
  String get printCardHelp;

  /// No description provided for @printFileName.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants NG Class'**
  String get printFileName;

  /// No description provided for @searchParents.
  ///
  /// In fr, this message translates to:
  /// **'Parents'**
  String get searchParents;

  /// No description provided for @searchHomeworkSection.
  ///
  /// In fr, this message translates to:
  /// **'Devoirs et évaluations'**
  String get searchHomeworkSection;

  /// No description provided for @searchKeysChoose.
  ///
  /// In fr, this message translates to:
  /// **'pour choisir'**
  String get searchKeysChoose;

  /// No description provided for @searchKeysOpen.
  ///
  /// In fr, this message translates to:
  /// **'pour ouvrir'**
  String get searchKeysOpen;

  /// No description provided for @searchKeysClose.
  ///
  /// In fr, this message translates to:
  /// **'pour fermer'**
  String get searchKeysClose;

  /// No description provided for @searchEverywhere.
  ///
  /// In fr, this message translates to:
  /// **'Partout :'**
  String get searchEverywhere;

  /// No description provided for @searchKeyEnter.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get searchKeyEnter;

  /// No description provided for @searchKeyEscape.
  ///
  /// In fr, this message translates to:
  /// **'Échap'**
  String get searchKeyEscape;

  /// No description provided for @searchNothing.
  ///
  /// In fr, this message translates to:
  /// **'Rien pour « {query} »'**
  String searchNothing(String query);

  /// No description provided for @searchNothingHint.
  ///
  /// In fr, this message translates to:
  /// **'Cherchez un élève (nom, identifiant, téléphone d\'un parent), un groupe, un document, un chapitre, un devoir ou une évaluation.'**
  String get searchNothingHint;

  /// No description provided for @searchOpen.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchOpen;

  /// No description provided for @copyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié.'**
  String get linkCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
