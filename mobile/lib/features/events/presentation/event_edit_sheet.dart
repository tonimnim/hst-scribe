import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Bottom-sheet editor for one [ExtractedEvent]. Pops with a partial
/// fields map ready to PATCH, or `null` if the nurse cancels.
///
/// Inputs are typed by event variant:
///   * vital_sign  → numeric keypad for `value` (+ unit kept as-is)
///   * medication  → dose numeric, route dropdown, indication free-text
///   * dispo       → notes free-text, criteria toggle
///   * note        → note_text free-text
class EventEditSheet extends StatefulWidget {
  const EventEditSheet({required this.event, super.key});

  final ExtractedEvent event;

  @override
  State<EventEditSheet> createState() => _EventEditSheetState();
}

class _EventEditSheetState extends State<EventEditSheet> {
  // Generic free-text controller used by some variants. Specific variants
  // bind their own additional controllers as needed.
  late final TextEditingController _primaryCtrl;
  late final TextEditingController _secondaryCtrl;

  MedicationRoute? _route;
  bool? _criteriaMet;

  @override
  void initState() {
    super.initState();
    _primaryCtrl = TextEditingController(text: _initialPrimary());
    _secondaryCtrl = TextEditingController(text: _initialSecondary());
    final e = widget.event;
    if (e is ExtractedMedicationAdministered) {
      _route = e.fields.route;
    } else if (e is ExtractedDispo) {
      _criteriaMet = e.fields.dischargeCriteriaMet;
    }
  }

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    super.dispose();
  }

  String _initialPrimary() {
    final e = widget.event;
    return switch (e) {
      ExtractedVitalSign(:final fields) => fields.value.toString(),
      ExtractedMedicationAdministered(:final fields) =>
        fields.doseValue.toString(),
      ExtractedDispo(:final fields) => fields.notes ?? '',
      ExtractedNote(:final fields) => fields.noteText,
    };
  }

  String _initialSecondary() {
    final e = widget.event;
    return switch (e) {
      ExtractedMedicationAdministered(:final fields) => fields.indication ?? '',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.eventCardEdit,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ..._buildFieldsForVariant(),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFieldsForVariant() {
    final e = widget.event;
    return switch (e) {
      ExtractedVitalSign(:final fields) => <Widget>[
        TextField(
          controller: _primaryCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(labelText: 'Value (${fields.unit})'),
        ),
      ],
      ExtractedMedicationAdministered(:final fields) => <Widget>[
        TextField(
          controller: _primaryCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: 'Dose (${fields.doseUnit.name})',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<MedicationRoute>(
          initialValue: _route,
          decoration: const InputDecoration(labelText: 'Route'),
          items: <DropdownMenuItem<MedicationRoute>>[
            for (final MedicationRoute r in MedicationRoute.values)
              DropdownMenuItem<MedicationRoute>(value: r, child: Text(r.name)),
          ],
          onChanged: (MedicationRoute? r) => setState(() => _route = r),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _secondaryCtrl,
          decoration: const InputDecoration(labelText: 'Indication'),
        ),
      ],
      ExtractedDispo() => <Widget>[
        TextField(
          controller: _primaryCtrl,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Notes'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Discharge criteria met'),
          value: _criteriaMet ?? false,
          onChanged: (bool v) => setState(() => _criteriaMet = v),
        ),
      ],
      ExtractedNote() => <Widget>[
        TextField(
          controller: _primaryCtrl,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
      ],
    };
  }

  void _onSave() {
    final e = widget.event;
    final fields = <String, Object?>{};
    switch (e) {
      case ExtractedVitalSign():
        final v = num.tryParse(_primaryCtrl.text);
        if (v != null) fields['value'] = v;
      case ExtractedMedicationAdministered():
        final dose = num.tryParse(_primaryCtrl.text);
        if (dose != null) fields['dose_value'] = dose;
        if (_route != null) fields['route'] = _routeWire(_route!);
        final indication = _secondaryCtrl.text.trim();
        if (indication.isNotEmpty) fields['indication'] = indication;
      case ExtractedDispo():
        final notes = _primaryCtrl.text.trim();
        if (notes.isNotEmpty) fields['notes'] = notes;
        if (_criteriaMet != null) {
          fields['discharge_criteria_met'] = _criteriaMet;
        }
      case ExtractedNote():
        final text = _primaryCtrl.text.trim();
        if (text.isNotEmpty) fields['note_text'] = text;
    }
    Navigator.of(context).pop(fields);
  }

  String _routeWire(MedicationRoute r) => switch (r) {
    MedicationRoute.iv => 'iv',
    MedicationRoute.im => 'im',
    MedicationRoute.po => 'po',
    MedicationRoute.sublingual => 'sublingual',
    MedicationRoute.topical => 'topical',
    MedicationRoute.inhaled => 'inhaled',
    MedicationRoute.intranasal => 'intranasal',
    MedicationRoute.rectal => 'rectal',
    MedicationRoute.subcutaneous => 'subcutaneous',
  };
}
