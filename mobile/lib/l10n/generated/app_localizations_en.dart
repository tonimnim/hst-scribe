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
  String get captureSessionEnded => 'Session ended.';

  @override
  String get captureReconnecting => 'Reconnecting…';

  @override
  String get captureMicDenied =>
      'Microphone access denied. Enable it in Settings to record.';

  @override
  String get captureVoiceCommandsOn => 'Voice commands on';

  @override
  String get captureVoiceCommandsOff => 'Voice commands off';

  @override
  String get captureTranscriptPlaceholder =>
      'Transcript will appear here once you start talking.';

  @override
  String get eventCardConfirm => 'Confirm';

  @override
  String get eventCardReject => 'Reject';

  @override
  String get eventCardEdit => 'Edit';

  @override
  String get eventCardSourceLabel => 'From utterance';

  @override
  String get eventConfidenceHigh => 'HIGH';

  @override
  String get eventConfidenceMedium => 'MEDIUM';

  @override
  String get eventConfidenceLow => 'LOW';

  @override
  String get eventListEmpty =>
      'No events yet. They\'ll appear here as the AI extracts them.';

  @override
  String get signTitle => 'Sign and submit';

  @override
  String get signBiometric => 'Sign with biometric';

  @override
  String get signPin => 'Use PIN instead';

  @override
  String get signSummaryConfirmed => 'Confirmed';

  @override
  String get signSummaryRejected => 'Rejected';

  @override
  String get signSummaryDraftsPending => 'Drafts pending';

  @override
  String get signBlockUntilResolved =>
      'Review or reject all pending drafts before signing.';

  @override
  String get signBiometricPrompt =>
      'Confirm with Face / Touch ID to sign the session.';

  @override
  String get signPinPrompt => 'Enter your 6-digit PIN to sign the session.';

  @override
  String get signSuccess => 'Session signed.';

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

  @override
  String get loginDevModeBanner => 'Dev mode — using fake authentication';

  @override
  String get sessionListSignedInAs => 'Signed in as';

  @override
  String get sessionListSignOut => 'Sign out';

  @override
  String get sessionStartCreate => 'Create session';

  @override
  String get sessionStartRescan => 'Scan again';

  @override
  String get sessionStartClearScan => 'Clear scan';

  @override
  String get sessionStartScannedSuffix => 'Scanned';

  @override
  String get sessionStartScannerError =>
      'Could not read the QR code. Try again.';

  @override
  String get sessionStartScannerHelp =>
      'Point the camera at the patient\'s wristband QR code.';

  @override
  String get sessionPatientConfirm => 'Confirm patient';

  @override
  String get patientContext => 'Patient context';

  @override
  String get patientConfirmTitle => 'Confirm patient';

  @override
  String get patientConfirmProcedureSection => 'Procedure';

  @override
  String get patientConfirmAllergiesSection => 'Allergies';

  @override
  String get patientConfirmAllergiesNone => 'No known allergies';

  @override
  String get patientConfirmMedsSection => 'Current medications';

  @override
  String get patientConfirmMedsNone => 'None on file';

  @override
  String get patientConfirmComorbiditiesSection => 'Comorbidities';

  @override
  String get patientConfirmYes => 'Yes, this is the patient';

  @override
  String get patientConfirmNo => 'No, scan again';
}
