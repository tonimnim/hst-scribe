// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HST Scribe';

  @override
  String get splashLoading => 'Loading…';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in with your HST account to continue.';

  @override
  String get loginButton => 'Sign in with HST';

  @override
  String get sessionListTitle => 'Sessions';

  @override
  String get sessionListEmpty =>
      'No active sessions. Start one to begin documenting.';

  @override
  String get sessionListNewSession => 'New session';

  @override
  String get sessionStartTitle => 'Confirm patient';

  @override
  String get sessionStartScanWristband => 'Scan wristband';

  @override
  String get sessionStartConfirmPrompt => 'Documenting for this patient?';

  @override
  String get sessionStartConfirm => 'Yes, this is the patient';

  @override
  String get sessionStartCancel => 'No, scan again';

  @override
  String get captureTitle => 'Capture';

  @override
  String get capturePushToTalk => 'Push to talk';

  @override
  String get capturePause => 'Pause';

  @override
  String get captureResume => 'Resume';

  @override
  String get captureEnd => 'End session';

  @override
  String get signTitle => 'Sign and submit';

  @override
  String get signBiometric => 'Sign with biometric';

  @override
  String get signPin => 'Use PIN instead';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get patientBannerTapToConfirm => 'Tap to confirm patient';

  @override
  String get patientBannerMrnPrefix => 'MRN';

  @override
  String get errorAuthInvalid =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthForbidden => 'You don\'t have access to this resource.';

  @override
  String get errorSessionNotFound => 'Session not found.';

  @override
  String get errorSessionExpired =>
      'This session has expired or was already signed.';

  @override
  String get errorPatientLocked =>
      'Another session is already active for this patient.';

  @override
  String get errorAudioFormat => 'Audio format is not supported by the server.';

  @override
  String get errorRateLimited => 'Too many requests. Please slow down.';

  @override
  String get errorExtractorFailed =>
      'We couldn\'t extract an event from that. You can retry.';

  @override
  String get errorNetwork => 'Network error. Reconnecting…';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';
}
