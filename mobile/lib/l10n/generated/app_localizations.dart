import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title shown in launcher, OS task switcher, and splash
  ///
  /// In en, this message translates to:
  /// **'HST Scribe'**
  String get appTitle;

  /// Splash screen loading indicator label
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your HST account to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with HST'**
  String get loginButton;

  /// No description provided for @sessionListTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionListTitle;

  /// No description provided for @sessionListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active sessions. Start one to begin documenting.'**
  String get sessionListEmpty;

  /// No description provided for @sessionListNewSession.
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get sessionListNewSession;

  /// No description provided for @sessionStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm patient'**
  String get sessionStartTitle;

  /// No description provided for @sessionStartScanWristband.
  ///
  /// In en, this message translates to:
  /// **'Scan wristband'**
  String get sessionStartScanWristband;

  /// No description provided for @sessionStartConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Documenting for this patient?'**
  String get sessionStartConfirmPrompt;

  /// No description provided for @sessionStartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, this is the patient'**
  String get sessionStartConfirm;

  /// No description provided for @sessionStartCancel.
  ///
  /// In en, this message translates to:
  /// **'No, scan again'**
  String get sessionStartCancel;

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureTitle;

  /// No description provided for @capturePushToTalk.
  ///
  /// In en, this message translates to:
  /// **'Push to talk'**
  String get capturePushToTalk;

  /// No description provided for @capturePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get capturePause;

  /// No description provided for @captureResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get captureResume;

  /// No description provided for @captureEnd.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get captureEnd;

  /// No description provided for @signTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign and submit'**
  String get signTitle;

  /// No description provided for @signBiometric.
  ///
  /// In en, this message translates to:
  /// **'Sign with biometric'**
  String get signBiometric;

  /// No description provided for @signPin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get signPin;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @patientBannerTapToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Tap to confirm patient'**
  String get patientBannerTapToConfirm;

  /// No description provided for @patientBannerMrnPrefix.
  ///
  /// In en, this message translates to:
  /// **'MRN'**
  String get patientBannerMrnPrefix;

  /// No description provided for @errorAuthInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorAuthInvalid;

  /// No description provided for @errorAuthForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this resource.'**
  String get errorAuthForbidden;

  /// No description provided for @errorSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found.'**
  String get errorSessionNotFound;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'This session has expired or was already signed.'**
  String get errorSessionExpired;

  /// No description provided for @errorPatientLocked.
  ///
  /// In en, this message translates to:
  /// **'Another session is already active for this patient.'**
  String get errorPatientLocked;

  /// No description provided for @errorAudioFormat.
  ///
  /// In en, this message translates to:
  /// **'Audio format is not supported by the server.'**
  String get errorAudioFormat;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please slow down.'**
  String get errorRateLimited;

  /// No description provided for @errorExtractorFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t extract an event from that. You can retry.'**
  String get errorExtractorFailed;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Reconnecting…'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @loginDevModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Dev mode — using fake authentication'**
  String get loginDevModeBanner;

  /// No description provided for @sessionListSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get sessionListSignedInAs;

  /// No description provided for @sessionListSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sessionListSignOut;

  /// No description provided for @sessionStartCreate.
  ///
  /// In en, this message translates to:
  /// **'Create session'**
  String get sessionStartCreate;

  /// No description provided for @sessionStartRescan.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get sessionStartRescan;

  /// No description provided for @sessionStartClearScan.
  ///
  /// In en, this message translates to:
  /// **'Clear scan'**
  String get sessionStartClearScan;

  /// No description provided for @sessionStartScannedSuffix.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get sessionStartScannedSuffix;

  /// No description provided for @sessionStartScannerError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the QR code. Try again.'**
  String get sessionStartScannerError;

  /// No description provided for @sessionStartScannerHelp.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the patient\'s wristband QR code.'**
  String get sessionStartScannerHelp;

  /// No description provided for @sessionPatientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm patient'**
  String get sessionPatientConfirm;

  /// No description provided for @patientContext.
  ///
  /// In en, this message translates to:
  /// **'Patient context'**
  String get patientContext;

  /// No description provided for @patientConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm patient'**
  String get patientConfirmTitle;

  /// No description provided for @patientConfirmProcedureSection.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get patientConfirmProcedureSection;

  /// No description provided for @patientConfirmAllergiesSection.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get patientConfirmAllergiesSection;

  /// No description provided for @patientConfirmAllergiesNone.
  ///
  /// In en, this message translates to:
  /// **'No known allergies'**
  String get patientConfirmAllergiesNone;

  /// No description provided for @patientConfirmMedsSection.
  ///
  /// In en, this message translates to:
  /// **'Current medications'**
  String get patientConfirmMedsSection;

  /// No description provided for @patientConfirmMedsNone.
  ///
  /// In en, this message translates to:
  /// **'None on file'**
  String get patientConfirmMedsNone;

  /// No description provided for @patientConfirmComorbiditiesSection.
  ///
  /// In en, this message translates to:
  /// **'Comorbidities'**
  String get patientConfirmComorbiditiesSection;

  /// No description provided for @patientConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, this is the patient'**
  String get patientConfirmYes;

  /// No description provided for @patientConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No, scan again'**
  String get patientConfirmNo;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
