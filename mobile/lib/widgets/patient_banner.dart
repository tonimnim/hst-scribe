import 'package:flutter/material.dart';
import 'package:hst_scribe/features/patient/domain/patient_context_model.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Top-of-screen patient identification banner.
///
/// Mandatory on every in-session screen per PRD §UX requirements:
/// "Patient identification banner pinned to top throughout session."
///
/// Renders only the wire-safe identifiers (initials + last 4 of MRN +
/// procedure). Never displays full name, full MRN, DOB, or other PHI.
///
/// Tap → fires [onTapToConfirm]; UI uses this to surface a confirmation
/// modal ("Is this the right patient?") for re-verification mid-session.
class PatientBanner extends StatelessWidget {
  const PatientBanner({
    required this.patient,
    this.onTapToConfirm,
    this.compact = false,
    super.key,
  });

  final PatientContextModel patient;
  final VoidCallback? onTapToConfirm;

  /// Compact mode reduces vertical padding for phone form factor.
  final bool compact;

  static const double _minTouchTarget = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final initialsStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onPrimaryContainer,
    );
    final mrnStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      letterSpacing: 0.5,
    );
    final procedureStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w500,
    );

    return Semantics(
      label:
          'Patient: ${patient.displayNameInitials}, '
          'MRN ending ${patient.mrnLast4}, ${patient.procedure}. '
          '${onTapToConfirm != null ? l10n.patientBannerTapToConfirm : ''}',
      button: onTapToConfirm != null,
      child: Material(
        color: theme.colorScheme.primaryContainer,
        child: InkWell(
          onTap: onTapToConfirm,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minTouchTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: compact ? 8 : 12,
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: compact ? 18 : 22,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      patient.displayNameInitials,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 14 : 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              patient.displayNameInitials,
                              style: initialsStyle,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '${l10n.patientBannerMrnPrefix} ••••${patient.mrnLast4}',
                                style: mrnStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          patient.procedure,
                          style: procedureStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  if (onTapToConfirm != null) ...<Widget>[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.verified_user_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
