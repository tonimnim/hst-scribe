import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hst_scribe/app/router.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/session/domain/session.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const AppLogger _log = AppLogger('SessionStartScreen');

/// Flow:
///   1. Tap "Scan wristband" → open `mobile_scanner` → returns `patientId`.
///   2. Loading while `POST /sessions` runs.
///   3. Navigate to `/sessions/:id/patient` for the confirm step.
class SessionStartScreen extends ConsumerStatefulWidget {
  const SessionStartScreen({super.key});

  @override
  ConsumerState<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends ConsumerState<SessionStartScreen> {
  AsyncValue<void> _flowState = const AsyncValue<void>.data(null);
  String? _scannedPatientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionStartTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sessionStartScannerHelp,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_scannedPatientId != null)
                _ScannedRow(
                  scanned: _scannedPatientId!,
                  onClear: _flowState.isLoading
                      ? null
                      : () => setState(() => _scannedPatientId = null),
                ),
              const Spacer(),
              FilledButton.icon(
                icon: _flowState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(
                  _scannedPatientId == null
                      ? l10n.sessionStartScanWristband
                      : l10n.sessionStartRescan,
                ),
                onPressed: _flowState.isLoading ? null : _openScanner,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.sessionStartCreate),
                onPressed:
                    (_scannedPatientId == null || _flowState.isLoading)
                        ? null
                        : _createSession,
              ),
              const SizedBox(height: 8),
              if (_flowState.hasError) _ErrorBanner(error: _flowState.error!),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScanner() async {
    final patientId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const _WristbandScannerPage(),
      ),
    );
    if (!mounted) return;
    if (patientId == null || patientId.isEmpty) return;
    setState(() {
      _scannedPatientId = patientId;
      _flowState = const AsyncValue<void>.data(null);
    });
  }

  Future<void> _createSession() async {
    final patientId = _scannedPatientId;
    if (patientId == null) return;
    final claims = ref.read(authClaimsProvider);
    if (claims == null) {
      _log.warn('createSession invoked without authenticated claims');
      return;
    }
    setState(() => _flowState = const AsyncValue<void>.loading());
    final repo = ref.read(sessionRepositoryProvider);
    final result = await AsyncValue.guard<Session>(() async {
      return repo.createSession(
        ascId: claims.ascId,
        patientId: patientId,
      );
    });
    if (!mounted) return;
    result.when<void>(
      data: (Session session) {
        ref.read(activeSessionProvider.notifier).set(session);
        setState(() => _flowState = const AsyncValue<void>.data(null));
        context.goNamed(
          Routes.sessionPatientConfirm,
          pathParameters: <String, String>{'sessionId': session.id},
        );
      },
      error: (Object err, StackTrace st) {
        _log.warn('createSession failed', error: err, stackTrace: st);
        setState(() => _flowState = AsyncValue<void>.error(err, st));
      },
      loading: () {},
    );
  }
}

class _ScannedRow extends StatelessWidget {
  const _ScannedRow({required this.scanned, required this.onClear});

  final String scanned;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // We intentionally show only the last 8 chars — a full patient_id is
    // not strictly PHI but principle of least surface still applies.
    final tail = scanned.length > 8
        ? scanned.substring(scanned.length - 8)
        : scanned;
    return Row(
      children: <Widget>[
        const Icon(Icons.qr_code, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${l10n.sessionStartScannedSuffix} •••$tail',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (onClear != null)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.sessionStartClearScan,
            onPressed: onClear,
          ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = _errorMessageFor(l10n, error);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _errorMessageFor(AppLocalizations l10n, Object error) {
  if (error is AppFailure) {
    return switch (error) {
      WireAppFailure(:final code) => switch (code) {
        WireErrorCode.authInvalid => l10n.errorAuthInvalid,
        WireErrorCode.authForbidden => l10n.errorAuthForbidden,
        WireErrorCode.sessionNotFound => l10n.errorSessionNotFound,
        WireErrorCode.sessionExpired => l10n.errorSessionExpired,
        WireErrorCode.patientLocked => l10n.errorPatientLocked,
        WireErrorCode.audioFormatUnsupported => l10n.errorAudioFormat,
        WireErrorCode.chunkOutOfOrder => l10n.errorUnexpected,
        WireErrorCode.rateLimited => l10n.errorRateLimited,
        WireErrorCode.extractorFailed => l10n.errorExtractorFailed,
        WireErrorCode.internal => l10n.errorUnexpected,
      },
      NetworkAppFailure() => l10n.errorNetwork,
      UnauthenticatedAppFailure() => l10n.errorAuthInvalid,
      PlatformAppFailure() => l10n.errorUnexpected,
      UnexpectedAppFailure() => l10n.errorUnexpected,
    };
  }
  return l10n.errorUnexpected;
}

/// Self-contained scanner page. Pops with the decoded barcode value, or
/// null if the user dismisses.
///
/// Camera/permission errors are surfaced as an inline message + cancel button
/// — we never leave the user stranded in a black screen.
class _WristbandScannerPage extends StatefulWidget {
  const _WristbandScannerPage();

  @override
  State<_WristbandScannerPage> createState() => _WristbandScannerPageState();
}

class _WristbandScannerPageState extends State<_WristbandScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const <BarcodeFormat>[
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.dataMatrix,
    ],
  );
  bool _handled = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionStartScanWristband)),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: _errorBuilder,
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final Barcode b in capture.barcodes) {
      final value = b.rawValue;
      if (value != null && value.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(value);
        return;
      }
    }
  }

  Widget _errorBuilder(
    BuildContext context,
    MobileScannerException error,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.no_photography, size: 56),
            const SizedBox(height: 16),
            Text(
              l10n.sessionStartScannerError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.sessionStartCancel),
            ),
          ],
        ),
      ),
    );
  }
}

