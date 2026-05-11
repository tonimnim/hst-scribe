// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extracted_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VitalSignFields _$VitalSignFieldsFromJson(Map<String, dynamic> json) {
  return _VitalSignFields.fromJson(json);
}

/// @nodoc
mixin _$VitalSignFields {
  @JsonKey(name: 'vital_type')
  VitalType get vitalType => throw _privateConstructorUsedError;
  num get value => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// Serializes this VitalSignFields to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VitalSignFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VitalSignFieldsCopyWith<VitalSignFields> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VitalSignFieldsCopyWith<$Res> {
  factory $VitalSignFieldsCopyWith(
    VitalSignFields value,
    $Res Function(VitalSignFields) then,
  ) = _$VitalSignFieldsCopyWithImpl<$Res, VitalSignFields>;
  @useResult
  $Res call({
    @JsonKey(name: 'vital_type') VitalType vitalType,
    num value,
    String unit,
  });
}

/// @nodoc
class _$VitalSignFieldsCopyWithImpl<$Res, $Val extends VitalSignFields>
    implements $VitalSignFieldsCopyWith<$Res> {
  _$VitalSignFieldsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VitalSignFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitalType = null,
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(
      _value.copyWith(
            vitalType: null == vitalType
                ? _value.vitalType
                : vitalType // ignore: cast_nullable_to_non_nullable
                      as VitalType,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as num,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VitalSignFieldsImplCopyWith<$Res>
    implements $VitalSignFieldsCopyWith<$Res> {
  factory _$$VitalSignFieldsImplCopyWith(
    _$VitalSignFieldsImpl value,
    $Res Function(_$VitalSignFieldsImpl) then,
  ) = __$$VitalSignFieldsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'vital_type') VitalType vitalType,
    num value,
    String unit,
  });
}

/// @nodoc
class __$$VitalSignFieldsImplCopyWithImpl<$Res>
    extends _$VitalSignFieldsCopyWithImpl<$Res, _$VitalSignFieldsImpl>
    implements _$$VitalSignFieldsImplCopyWith<$Res> {
  __$$VitalSignFieldsImplCopyWithImpl(
    _$VitalSignFieldsImpl _value,
    $Res Function(_$VitalSignFieldsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VitalSignFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitalType = null,
    Object? value = null,
    Object? unit = null,
  }) {
    return _then(
      _$VitalSignFieldsImpl(
        vitalType: null == vitalType
            ? _value.vitalType
            : vitalType // ignore: cast_nullable_to_non_nullable
                  as VitalType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as num,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VitalSignFieldsImpl implements _VitalSignFields {
  const _$VitalSignFieldsImpl({
    @JsonKey(name: 'vital_type') required this.vitalType,
    required this.value,
    required this.unit,
  });

  factory _$VitalSignFieldsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VitalSignFieldsImplFromJson(json);

  @override
  @JsonKey(name: 'vital_type')
  final VitalType vitalType;
  @override
  final num value;
  @override
  final String unit;

  @override
  String toString() {
    return 'VitalSignFields(vitalType: $vitalType, value: $value, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalSignFieldsImpl &&
            (identical(other.vitalType, vitalType) ||
                other.vitalType == vitalType) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, vitalType, value, unit);

  /// Create a copy of VitalSignFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalSignFieldsImplCopyWith<_$VitalSignFieldsImpl> get copyWith =>
      __$$VitalSignFieldsImplCopyWithImpl<_$VitalSignFieldsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VitalSignFieldsImplToJson(this);
  }
}

abstract class _VitalSignFields implements VitalSignFields {
  const factory _VitalSignFields({
    @JsonKey(name: 'vital_type') required final VitalType vitalType,
    required final num value,
    required final String unit,
  }) = _$VitalSignFieldsImpl;

  factory _VitalSignFields.fromJson(Map<String, dynamic> json) =
      _$VitalSignFieldsImpl.fromJson;

  @override
  @JsonKey(name: 'vital_type')
  VitalType get vitalType;
  @override
  num get value;
  @override
  String get unit;

  /// Create a copy of VitalSignFields
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VitalSignFieldsImplCopyWith<_$VitalSignFieldsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicationAdministeredFields _$MedicationAdministeredFieldsFromJson(
  Map<String, dynamic> json,
) {
  return _MedicationAdministeredFields.fromJson(json);
}

/// @nodoc
mixin _$MedicationAdministeredFields {
  @JsonKey(name: 'medication_name')
  String get medicationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'rxnorm_code')
  String get rxnormCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'dose_value')
  num get doseValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'dose_unit')
  DoseUnit get doseUnit => throw _privateConstructorUsedError;
  MedicationRoute get route => throw _privateConstructorUsedError;
  String? get indication => throw _privateConstructorUsedError;

  /// Serializes this MedicationAdministeredFields to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicationAdministeredFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationAdministeredFieldsCopyWith<MedicationAdministeredFields>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationAdministeredFieldsCopyWith<$Res> {
  factory $MedicationAdministeredFieldsCopyWith(
    MedicationAdministeredFields value,
    $Res Function(MedicationAdministeredFields) then,
  ) =
      _$MedicationAdministeredFieldsCopyWithImpl<
        $Res,
        MedicationAdministeredFields
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'medication_name') String medicationName,
    @JsonKey(name: 'rxnorm_code') String rxnormCode,
    @JsonKey(name: 'dose_value') num doseValue,
    @JsonKey(name: 'dose_unit') DoseUnit doseUnit,
    MedicationRoute route,
    String? indication,
  });
}

/// @nodoc
class _$MedicationAdministeredFieldsCopyWithImpl<
  $Res,
  $Val extends MedicationAdministeredFields
>
    implements $MedicationAdministeredFieldsCopyWith<$Res> {
  _$MedicationAdministeredFieldsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationAdministeredFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medicationName = null,
    Object? rxnormCode = null,
    Object? doseValue = null,
    Object? doseUnit = null,
    Object? route = null,
    Object? indication = freezed,
  }) {
    return _then(
      _value.copyWith(
            medicationName: null == medicationName
                ? _value.medicationName
                : medicationName // ignore: cast_nullable_to_non_nullable
                      as String,
            rxnormCode: null == rxnormCode
                ? _value.rxnormCode
                : rxnormCode // ignore: cast_nullable_to_non_nullable
                      as String,
            doseValue: null == doseValue
                ? _value.doseValue
                : doseValue // ignore: cast_nullable_to_non_nullable
                      as num,
            doseUnit: null == doseUnit
                ? _value.doseUnit
                : doseUnit // ignore: cast_nullable_to_non_nullable
                      as DoseUnit,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as MedicationRoute,
            indication: freezed == indication
                ? _value.indication
                : indication // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicationAdministeredFieldsImplCopyWith<$Res>
    implements $MedicationAdministeredFieldsCopyWith<$Res> {
  factory _$$MedicationAdministeredFieldsImplCopyWith(
    _$MedicationAdministeredFieldsImpl value,
    $Res Function(_$MedicationAdministeredFieldsImpl) then,
  ) = __$$MedicationAdministeredFieldsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'medication_name') String medicationName,
    @JsonKey(name: 'rxnorm_code') String rxnormCode,
    @JsonKey(name: 'dose_value') num doseValue,
    @JsonKey(name: 'dose_unit') DoseUnit doseUnit,
    MedicationRoute route,
    String? indication,
  });
}

/// @nodoc
class __$$MedicationAdministeredFieldsImplCopyWithImpl<$Res>
    extends
        _$MedicationAdministeredFieldsCopyWithImpl<
          $Res,
          _$MedicationAdministeredFieldsImpl
        >
    implements _$$MedicationAdministeredFieldsImplCopyWith<$Res> {
  __$$MedicationAdministeredFieldsImplCopyWithImpl(
    _$MedicationAdministeredFieldsImpl _value,
    $Res Function(_$MedicationAdministeredFieldsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationAdministeredFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medicationName = null,
    Object? rxnormCode = null,
    Object? doseValue = null,
    Object? doseUnit = null,
    Object? route = null,
    Object? indication = freezed,
  }) {
    return _then(
      _$MedicationAdministeredFieldsImpl(
        medicationName: null == medicationName
            ? _value.medicationName
            : medicationName // ignore: cast_nullable_to_non_nullable
                  as String,
        rxnormCode: null == rxnormCode
            ? _value.rxnormCode
            : rxnormCode // ignore: cast_nullable_to_non_nullable
                  as String,
        doseValue: null == doseValue
            ? _value.doseValue
            : doseValue // ignore: cast_nullable_to_non_nullable
                  as num,
        doseUnit: null == doseUnit
            ? _value.doseUnit
            : doseUnit // ignore: cast_nullable_to_non_nullable
                  as DoseUnit,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as MedicationRoute,
        indication: freezed == indication
            ? _value.indication
            : indication // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationAdministeredFieldsImpl
    implements _MedicationAdministeredFields {
  const _$MedicationAdministeredFieldsImpl({
    @JsonKey(name: 'medication_name') required this.medicationName,
    @JsonKey(name: 'rxnorm_code') required this.rxnormCode,
    @JsonKey(name: 'dose_value') required this.doseValue,
    @JsonKey(name: 'dose_unit') required this.doseUnit,
    required this.route,
    this.indication,
  });

  factory _$MedicationAdministeredFieldsImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MedicationAdministeredFieldsImplFromJson(json);

  @override
  @JsonKey(name: 'medication_name')
  final String medicationName;
  @override
  @JsonKey(name: 'rxnorm_code')
  final String rxnormCode;
  @override
  @JsonKey(name: 'dose_value')
  final num doseValue;
  @override
  @JsonKey(name: 'dose_unit')
  final DoseUnit doseUnit;
  @override
  final MedicationRoute route;
  @override
  final String? indication;

  @override
  String toString() {
    return 'MedicationAdministeredFields(medicationName: $medicationName, rxnormCode: $rxnormCode, doseValue: $doseValue, doseUnit: $doseUnit, route: $route, indication: $indication)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationAdministeredFieldsImpl &&
            (identical(other.medicationName, medicationName) ||
                other.medicationName == medicationName) &&
            (identical(other.rxnormCode, rxnormCode) ||
                other.rxnormCode == rxnormCode) &&
            (identical(other.doseValue, doseValue) ||
                other.doseValue == doseValue) &&
            (identical(other.doseUnit, doseUnit) ||
                other.doseUnit == doseUnit) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.indication, indication) ||
                other.indication == indication));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    medicationName,
    rxnormCode,
    doseValue,
    doseUnit,
    route,
    indication,
  );

  /// Create a copy of MedicationAdministeredFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationAdministeredFieldsImplCopyWith<
    _$MedicationAdministeredFieldsImpl
  >
  get copyWith =>
      __$$MedicationAdministeredFieldsImplCopyWithImpl<
        _$MedicationAdministeredFieldsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationAdministeredFieldsImplToJson(this);
  }
}

abstract class _MedicationAdministeredFields
    implements MedicationAdministeredFields {
  const factory _MedicationAdministeredFields({
    @JsonKey(name: 'medication_name') required final String medicationName,
    @JsonKey(name: 'rxnorm_code') required final String rxnormCode,
    @JsonKey(name: 'dose_value') required final num doseValue,
    @JsonKey(name: 'dose_unit') required final DoseUnit doseUnit,
    required final MedicationRoute route,
    final String? indication,
  }) = _$MedicationAdministeredFieldsImpl;

  factory _MedicationAdministeredFields.fromJson(Map<String, dynamic> json) =
      _$MedicationAdministeredFieldsImpl.fromJson;

  @override
  @JsonKey(name: 'medication_name')
  String get medicationName;
  @override
  @JsonKey(name: 'rxnorm_code')
  String get rxnormCode;
  @override
  @JsonKey(name: 'dose_value')
  num get doseValue;
  @override
  @JsonKey(name: 'dose_unit')
  DoseUnit get doseUnit;
  @override
  MedicationRoute get route;
  @override
  String? get indication;

  /// Create a copy of MedicationAdministeredFields
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationAdministeredFieldsImplCopyWith<
    _$MedicationAdministeredFieldsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

DispoFields _$DispoFieldsFromJson(Map<String, dynamic> json) {
  return _DispoFields.fromJson(json);
}

/// @nodoc
mixin _$DispoFields {
  @JsonKey(name: 'disposition_type')
  DispositionType get dispositionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'discharge_criteria_met')
  bool? get dischargeCriteriaMet => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this DispoFields to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DispoFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DispoFieldsCopyWith<DispoFields> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispoFieldsCopyWith<$Res> {
  factory $DispoFieldsCopyWith(
    DispoFields value,
    $Res Function(DispoFields) then,
  ) = _$DispoFieldsCopyWithImpl<$Res, DispoFields>;
  @useResult
  $Res call({
    @JsonKey(name: 'disposition_type') DispositionType dispositionType,
    @JsonKey(name: 'discharge_criteria_met') bool? dischargeCriteriaMet,
    String? notes,
  });
}

/// @nodoc
class _$DispoFieldsCopyWithImpl<$Res, $Val extends DispoFields>
    implements $DispoFieldsCopyWith<$Res> {
  _$DispoFieldsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DispoFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dispositionType = null,
    Object? dischargeCriteriaMet = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            dispositionType: null == dispositionType
                ? _value.dispositionType
                : dispositionType // ignore: cast_nullable_to_non_nullable
                      as DispositionType,
            dischargeCriteriaMet: freezed == dischargeCriteriaMet
                ? _value.dischargeCriteriaMet
                : dischargeCriteriaMet // ignore: cast_nullable_to_non_nullable
                      as bool?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DispoFieldsImplCopyWith<$Res>
    implements $DispoFieldsCopyWith<$Res> {
  factory _$$DispoFieldsImplCopyWith(
    _$DispoFieldsImpl value,
    $Res Function(_$DispoFieldsImpl) then,
  ) = __$$DispoFieldsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'disposition_type') DispositionType dispositionType,
    @JsonKey(name: 'discharge_criteria_met') bool? dischargeCriteriaMet,
    String? notes,
  });
}

/// @nodoc
class __$$DispoFieldsImplCopyWithImpl<$Res>
    extends _$DispoFieldsCopyWithImpl<$Res, _$DispoFieldsImpl>
    implements _$$DispoFieldsImplCopyWith<$Res> {
  __$$DispoFieldsImplCopyWithImpl(
    _$DispoFieldsImpl _value,
    $Res Function(_$DispoFieldsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DispoFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dispositionType = null,
    Object? dischargeCriteriaMet = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$DispoFieldsImpl(
        dispositionType: null == dispositionType
            ? _value.dispositionType
            : dispositionType // ignore: cast_nullable_to_non_nullable
                  as DispositionType,
        dischargeCriteriaMet: freezed == dischargeCriteriaMet
            ? _value.dischargeCriteriaMet
            : dischargeCriteriaMet // ignore: cast_nullable_to_non_nullable
                  as bool?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DispoFieldsImpl implements _DispoFields {
  const _$DispoFieldsImpl({
    @JsonKey(name: 'disposition_type') required this.dispositionType,
    @JsonKey(name: 'discharge_criteria_met') this.dischargeCriteriaMet,
    this.notes,
  });

  factory _$DispoFieldsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispoFieldsImplFromJson(json);

  @override
  @JsonKey(name: 'disposition_type')
  final DispositionType dispositionType;
  @override
  @JsonKey(name: 'discharge_criteria_met')
  final bool? dischargeCriteriaMet;
  @override
  final String? notes;

  @override
  String toString() {
    return 'DispoFields(dispositionType: $dispositionType, dischargeCriteriaMet: $dischargeCriteriaMet, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispoFieldsImpl &&
            (identical(other.dispositionType, dispositionType) ||
                other.dispositionType == dispositionType) &&
            (identical(other.dischargeCriteriaMet, dischargeCriteriaMet) ||
                other.dischargeCriteriaMet == dischargeCriteriaMet) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dispositionType, dischargeCriteriaMet, notes);

  /// Create a copy of DispoFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DispoFieldsImplCopyWith<_$DispoFieldsImpl> get copyWith =>
      __$$DispoFieldsImplCopyWithImpl<_$DispoFieldsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispoFieldsImplToJson(this);
  }
}

abstract class _DispoFields implements DispoFields {
  const factory _DispoFields({
    @JsonKey(name: 'disposition_type')
    required final DispositionType dispositionType,
    @JsonKey(name: 'discharge_criteria_met') final bool? dischargeCriteriaMet,
    final String? notes,
  }) = _$DispoFieldsImpl;

  factory _DispoFields.fromJson(Map<String, dynamic> json) =
      _$DispoFieldsImpl.fromJson;

  @override
  @JsonKey(name: 'disposition_type')
  DispositionType get dispositionType;
  @override
  @JsonKey(name: 'discharge_criteria_met')
  bool? get dischargeCriteriaMet;
  @override
  String? get notes;

  /// Create a copy of DispoFields
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DispoFieldsImplCopyWith<_$DispoFieldsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NoteFields _$NoteFieldsFromJson(Map<String, dynamic> json) {
  return _NoteFields.fromJson(json);
}

/// @nodoc
mixin _$NoteFields {
  @JsonKey(name: 'note_text')
  String get noteText => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this NoteFields to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoteFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteFieldsCopyWith<NoteFields> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteFieldsCopyWith<$Res> {
  factory $NoteFieldsCopyWith(
    NoteFields value,
    $Res Function(NoteFields) then,
  ) = _$NoteFieldsCopyWithImpl<$Res, NoteFields>;
  @useResult
  $Res call({@JsonKey(name: 'note_text') String noteText, List<String> tags});
}

/// @nodoc
class _$NoteFieldsCopyWithImpl<$Res, $Val extends NoteFields>
    implements $NoteFieldsCopyWith<$Res> {
  _$NoteFieldsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? noteText = null, Object? tags = null}) {
    return _then(
      _value.copyWith(
            noteText: null == noteText
                ? _value.noteText
                : noteText // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoteFieldsImplCopyWith<$Res>
    implements $NoteFieldsCopyWith<$Res> {
  factory _$$NoteFieldsImplCopyWith(
    _$NoteFieldsImpl value,
    $Res Function(_$NoteFieldsImpl) then,
  ) = __$$NoteFieldsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'note_text') String noteText, List<String> tags});
}

/// @nodoc
class __$$NoteFieldsImplCopyWithImpl<$Res>
    extends _$NoteFieldsCopyWithImpl<$Res, _$NoteFieldsImpl>
    implements _$$NoteFieldsImplCopyWith<$Res> {
  __$$NoteFieldsImplCopyWithImpl(
    _$NoteFieldsImpl _value,
    $Res Function(_$NoteFieldsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteFields
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? noteText = null, Object? tags = null}) {
    return _then(
      _$NoteFieldsImpl(
        noteText: null == noteText
            ? _value.noteText
            : noteText // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteFieldsImpl implements _NoteFields {
  const _$NoteFieldsImpl({
    @JsonKey(name: 'note_text') required this.noteText,
    final List<String> tags = const <String>[],
  }) : _tags = tags;

  factory _$NoteFieldsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteFieldsImplFromJson(json);

  @override
  @JsonKey(name: 'note_text')
  final String noteText;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'NoteFields(noteText: $noteText, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteFieldsImpl &&
            (identical(other.noteText, noteText) ||
                other.noteText == noteText) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    noteText,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of NoteFields
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteFieldsImplCopyWith<_$NoteFieldsImpl> get copyWith =>
      __$$NoteFieldsImplCopyWithImpl<_$NoteFieldsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteFieldsImplToJson(this);
  }
}

abstract class _NoteFields implements NoteFields {
  const factory _NoteFields({
    @JsonKey(name: 'note_text') required final String noteText,
    final List<String> tags,
  }) = _$NoteFieldsImpl;

  factory _NoteFields.fromJson(Map<String, dynamic> json) =
      _$NoteFieldsImpl.fromJson;

  @override
  @JsonKey(name: 'note_text')
  String get noteText;
  @override
  List<String> get tags;

  /// Create a copy of NoteFields
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteFieldsImplCopyWith<_$NoteFieldsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExtractedEvent _$ExtractedEventFromJson(Map<String, dynamic> json) {
  switch (json['event_type']) {
    case 'vital_sign':
      return ExtractedVitalSign.fromJson(json);
    case 'medication_administered':
      return ExtractedMedicationAdministered.fromJson(json);
    case 'dispo':
      return ExtractedDispo.fromJson(json);
    case 'note':
      return ExtractedNote.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'event_type',
        'ExtractedEvent',
        'Invalid union type "${json['event_type']}"!',
      );
  }
}

/// @nodoc
mixin _$ExtractedEvent {
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  Object get fields => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_utterance')
  String get sourceUtterance => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'extracted_at')
  DateTime get extractedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_time')
  DateTime get eventTime => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    vitalSign,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    medicationAdministered,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    dispo,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExtractedVitalSign value) vitalSign,
    required TResult Function(ExtractedMedicationAdministered value)
    medicationAdministered,
    required TResult Function(ExtractedDispo value) dispo,
    required TResult Function(ExtractedNote value) note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExtractedVitalSign value)? vitalSign,
    TResult? Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult? Function(ExtractedDispo value)? dispo,
    TResult? Function(ExtractedNote value)? note,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExtractedVitalSign value)? vitalSign,
    TResult Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult Function(ExtractedDispo value)? dispo,
    TResult Function(ExtractedNote value)? note,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ExtractedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExtractedEventCopyWith<ExtractedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtractedEventCopyWith<$Res> {
  factory $ExtractedEventCopyWith(
    ExtractedEvent value,
    $Res Function(ExtractedEvent) then,
  ) = _$ExtractedEventCopyWithImpl<$Res, ExtractedEvent>;
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    double confidence,
    @JsonKey(name: 'source_utterance') String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') DateTime extractedAt,
    @JsonKey(name: 'event_time') DateTime eventTime,
  });
}

/// @nodoc
class _$ExtractedEventCopyWithImpl<$Res, $Val extends ExtractedEvent>
    implements $ExtractedEventCopyWith<$Res> {
  _$ExtractedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? confidence = null,
    Object? sourceUtterance = null,
    Object? sourceTranscriptIds = null,
    Object? extractedAt = null,
    Object? eventTime = null,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            sourceUtterance: null == sourceUtterance
                ? _value.sourceUtterance
                : sourceUtterance // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceTranscriptIds: null == sourceTranscriptIds
                ? _value.sourceTranscriptIds
                : sourceTranscriptIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            extractedAt: null == extractedAt
                ? _value.extractedAt
                : extractedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            eventTime: null == eventTime
                ? _value.eventTime
                : eventTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExtractedVitalSignImplCopyWith<$Res>
    implements $ExtractedEventCopyWith<$Res> {
  factory _$$ExtractedVitalSignImplCopyWith(
    _$ExtractedVitalSignImpl value,
    $Res Function(_$ExtractedVitalSignImpl) then,
  ) = __$$ExtractedVitalSignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    VitalSignFields fields,
    double confidence,
    @JsonKey(name: 'source_utterance') String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') DateTime extractedAt,
    @JsonKey(name: 'event_time') DateTime eventTime,
  });

  $VitalSignFieldsCopyWith<$Res> get fields;
}

/// @nodoc
class __$$ExtractedVitalSignImplCopyWithImpl<$Res>
    extends _$ExtractedEventCopyWithImpl<$Res, _$ExtractedVitalSignImpl>
    implements _$$ExtractedVitalSignImplCopyWith<$Res> {
  __$$ExtractedVitalSignImplCopyWithImpl(
    _$ExtractedVitalSignImpl _value,
    $Res Function(_$ExtractedVitalSignImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? fields = null,
    Object? confidence = null,
    Object? sourceUtterance = null,
    Object? sourceTranscriptIds = null,
    Object? extractedAt = null,
    Object? eventTime = null,
  }) {
    return _then(
      _$ExtractedVitalSignImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        fields: null == fields
            ? _value.fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as VitalSignFields,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        sourceUtterance: null == sourceUtterance
            ? _value.sourceUtterance
            : sourceUtterance // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceTranscriptIds: null == sourceTranscriptIds
            ? _value._sourceTranscriptIds
            : sourceTranscriptIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        extractedAt: null == extractedAt
            ? _value.extractedAt
            : extractedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventTime: null == eventTime
            ? _value.eventTime
            : eventTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VitalSignFieldsCopyWith<$Res> get fields {
    return $VitalSignFieldsCopyWith<$Res>(_value.fields, (value) {
      return _then(_value.copyWith(fields: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractedVitalSignImpl implements ExtractedVitalSign {
  const _$ExtractedVitalSignImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.fields,
    required this.confidence,
    @JsonKey(name: 'source_utterance') required this.sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required this.extractedAt,
    @JsonKey(name: 'event_time') required this.eventTime,
    final String? $type,
  }) : _sourceTranscriptIds = sourceTranscriptIds,
       $type = $type ?? 'vital_sign';

  factory _$ExtractedVitalSignImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractedVitalSignImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final VitalSignFields fields;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'source_utterance')
  final String sourceUtterance;
  final List<String> _sourceTranscriptIds;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds {
    if (_sourceTranscriptIds is EqualUnmodifiableListView)
      return _sourceTranscriptIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceTranscriptIds);
  }

  @override
  @JsonKey(name: 'extracted_at')
  final DateTime extractedAt;
  @override
  @JsonKey(name: 'event_time')
  final DateTime eventTime;

  @JsonKey(name: 'event_type')
  final String $type;

  @override
  String toString() {
    return 'ExtractedEvent.vitalSign(eventId: $eventId, fields: $fields, confidence: $confidence, sourceUtterance: $sourceUtterance, sourceTranscriptIds: $sourceTranscriptIds, extractedAt: $extractedAt, eventTime: $eventTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractedVitalSignImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.fields, fields) || other.fields == fields) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sourceUtterance, sourceUtterance) ||
                other.sourceUtterance == sourceUtterance) &&
            const DeepCollectionEquality().equals(
              other._sourceTranscriptIds,
              _sourceTranscriptIds,
            ) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    fields,
    confidence,
    sourceUtterance,
    const DeepCollectionEquality().hash(_sourceTranscriptIds),
    extractedAt,
    eventTime,
  );

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractedVitalSignImplCopyWith<_$ExtractedVitalSignImpl> get copyWith =>
      __$$ExtractedVitalSignImplCopyWithImpl<_$ExtractedVitalSignImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    vitalSign,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    medicationAdministered,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    dispo,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    note,
  }) {
    return vitalSign(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
  }) {
    return vitalSign?.call(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
    required TResult orElse(),
  }) {
    if (vitalSign != null) {
      return vitalSign(
        eventId,
        fields,
        confidence,
        sourceUtterance,
        sourceTranscriptIds,
        extractedAt,
        eventTime,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExtractedVitalSign value) vitalSign,
    required TResult Function(ExtractedMedicationAdministered value)
    medicationAdministered,
    required TResult Function(ExtractedDispo value) dispo,
    required TResult Function(ExtractedNote value) note,
  }) {
    return vitalSign(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExtractedVitalSign value)? vitalSign,
    TResult? Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult? Function(ExtractedDispo value)? dispo,
    TResult? Function(ExtractedNote value)? note,
  }) {
    return vitalSign?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExtractedVitalSign value)? vitalSign,
    TResult Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult Function(ExtractedDispo value)? dispo,
    TResult Function(ExtractedNote value)? note,
    required TResult orElse(),
  }) {
    if (vitalSign != null) {
      return vitalSign(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractedVitalSignImplToJson(this);
  }
}

abstract class ExtractedVitalSign implements ExtractedEvent {
  const factory ExtractedVitalSign({
    @JsonKey(name: 'event_id') required final String eventId,
    required final VitalSignFields fields,
    required final double confidence,
    @JsonKey(name: 'source_utterance') required final String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required final DateTime extractedAt,
    @JsonKey(name: 'event_time') required final DateTime eventTime,
  }) = _$ExtractedVitalSignImpl;

  factory ExtractedVitalSign.fromJson(Map<String, dynamic> json) =
      _$ExtractedVitalSignImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  VitalSignFields get fields;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'source_utterance')
  String get sourceUtterance;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds;
  @override
  @JsonKey(name: 'extracted_at')
  DateTime get extractedAt;
  @override
  @JsonKey(name: 'event_time')
  DateTime get eventTime;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractedVitalSignImplCopyWith<_$ExtractedVitalSignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExtractedMedicationAdministeredImplCopyWith<$Res>
    implements $ExtractedEventCopyWith<$Res> {
  factory _$$ExtractedMedicationAdministeredImplCopyWith(
    _$ExtractedMedicationAdministeredImpl value,
    $Res Function(_$ExtractedMedicationAdministeredImpl) then,
  ) = __$$ExtractedMedicationAdministeredImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    MedicationAdministeredFields fields,
    double confidence,
    @JsonKey(name: 'source_utterance') String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') DateTime extractedAt,
    @JsonKey(name: 'event_time') DateTime eventTime,
  });

  $MedicationAdministeredFieldsCopyWith<$Res> get fields;
}

/// @nodoc
class __$$ExtractedMedicationAdministeredImplCopyWithImpl<$Res>
    extends
        _$ExtractedEventCopyWithImpl<
          $Res,
          _$ExtractedMedicationAdministeredImpl
        >
    implements _$$ExtractedMedicationAdministeredImplCopyWith<$Res> {
  __$$ExtractedMedicationAdministeredImplCopyWithImpl(
    _$ExtractedMedicationAdministeredImpl _value,
    $Res Function(_$ExtractedMedicationAdministeredImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? fields = null,
    Object? confidence = null,
    Object? sourceUtterance = null,
    Object? sourceTranscriptIds = null,
    Object? extractedAt = null,
    Object? eventTime = null,
  }) {
    return _then(
      _$ExtractedMedicationAdministeredImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        fields: null == fields
            ? _value.fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as MedicationAdministeredFields,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        sourceUtterance: null == sourceUtterance
            ? _value.sourceUtterance
            : sourceUtterance // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceTranscriptIds: null == sourceTranscriptIds
            ? _value._sourceTranscriptIds
            : sourceTranscriptIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        extractedAt: null == extractedAt
            ? _value.extractedAt
            : extractedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventTime: null == eventTime
            ? _value.eventTime
            : eventTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationAdministeredFieldsCopyWith<$Res> get fields {
    return $MedicationAdministeredFieldsCopyWith<$Res>(_value.fields, (value) {
      return _then(_value.copyWith(fields: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractedMedicationAdministeredImpl
    implements ExtractedMedicationAdministered {
  const _$ExtractedMedicationAdministeredImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.fields,
    required this.confidence,
    @JsonKey(name: 'source_utterance') required this.sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required this.extractedAt,
    @JsonKey(name: 'event_time') required this.eventTime,
    final String? $type,
  }) : _sourceTranscriptIds = sourceTranscriptIds,
       $type = $type ?? 'medication_administered';

  factory _$ExtractedMedicationAdministeredImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ExtractedMedicationAdministeredImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final MedicationAdministeredFields fields;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'source_utterance')
  final String sourceUtterance;
  final List<String> _sourceTranscriptIds;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds {
    if (_sourceTranscriptIds is EqualUnmodifiableListView)
      return _sourceTranscriptIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceTranscriptIds);
  }

  @override
  @JsonKey(name: 'extracted_at')
  final DateTime extractedAt;
  @override
  @JsonKey(name: 'event_time')
  final DateTime eventTime;

  @JsonKey(name: 'event_type')
  final String $type;

  @override
  String toString() {
    return 'ExtractedEvent.medicationAdministered(eventId: $eventId, fields: $fields, confidence: $confidence, sourceUtterance: $sourceUtterance, sourceTranscriptIds: $sourceTranscriptIds, extractedAt: $extractedAt, eventTime: $eventTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractedMedicationAdministeredImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.fields, fields) || other.fields == fields) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sourceUtterance, sourceUtterance) ||
                other.sourceUtterance == sourceUtterance) &&
            const DeepCollectionEquality().equals(
              other._sourceTranscriptIds,
              _sourceTranscriptIds,
            ) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    fields,
    confidence,
    sourceUtterance,
    const DeepCollectionEquality().hash(_sourceTranscriptIds),
    extractedAt,
    eventTime,
  );

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractedMedicationAdministeredImplCopyWith<
    _$ExtractedMedicationAdministeredImpl
  >
  get copyWith =>
      __$$ExtractedMedicationAdministeredImplCopyWithImpl<
        _$ExtractedMedicationAdministeredImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    vitalSign,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    medicationAdministered,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    dispo,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    note,
  }) {
    return medicationAdministered(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
  }) {
    return medicationAdministered?.call(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
    required TResult orElse(),
  }) {
    if (medicationAdministered != null) {
      return medicationAdministered(
        eventId,
        fields,
        confidence,
        sourceUtterance,
        sourceTranscriptIds,
        extractedAt,
        eventTime,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExtractedVitalSign value) vitalSign,
    required TResult Function(ExtractedMedicationAdministered value)
    medicationAdministered,
    required TResult Function(ExtractedDispo value) dispo,
    required TResult Function(ExtractedNote value) note,
  }) {
    return medicationAdministered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExtractedVitalSign value)? vitalSign,
    TResult? Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult? Function(ExtractedDispo value)? dispo,
    TResult? Function(ExtractedNote value)? note,
  }) {
    return medicationAdministered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExtractedVitalSign value)? vitalSign,
    TResult Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult Function(ExtractedDispo value)? dispo,
    TResult Function(ExtractedNote value)? note,
    required TResult orElse(),
  }) {
    if (medicationAdministered != null) {
      return medicationAdministered(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractedMedicationAdministeredImplToJson(this);
  }
}

abstract class ExtractedMedicationAdministered implements ExtractedEvent {
  const factory ExtractedMedicationAdministered({
    @JsonKey(name: 'event_id') required final String eventId,
    required final MedicationAdministeredFields fields,
    required final double confidence,
    @JsonKey(name: 'source_utterance') required final String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required final DateTime extractedAt,
    @JsonKey(name: 'event_time') required final DateTime eventTime,
  }) = _$ExtractedMedicationAdministeredImpl;

  factory ExtractedMedicationAdministered.fromJson(Map<String, dynamic> json) =
      _$ExtractedMedicationAdministeredImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  MedicationAdministeredFields get fields;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'source_utterance')
  String get sourceUtterance;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds;
  @override
  @JsonKey(name: 'extracted_at')
  DateTime get extractedAt;
  @override
  @JsonKey(name: 'event_time')
  DateTime get eventTime;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractedMedicationAdministeredImplCopyWith<
    _$ExtractedMedicationAdministeredImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExtractedDispoImplCopyWith<$Res>
    implements $ExtractedEventCopyWith<$Res> {
  factory _$$ExtractedDispoImplCopyWith(
    _$ExtractedDispoImpl value,
    $Res Function(_$ExtractedDispoImpl) then,
  ) = __$$ExtractedDispoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    DispoFields fields,
    double confidence,
    @JsonKey(name: 'source_utterance') String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') DateTime extractedAt,
    @JsonKey(name: 'event_time') DateTime eventTime,
  });

  $DispoFieldsCopyWith<$Res> get fields;
}

/// @nodoc
class __$$ExtractedDispoImplCopyWithImpl<$Res>
    extends _$ExtractedEventCopyWithImpl<$Res, _$ExtractedDispoImpl>
    implements _$$ExtractedDispoImplCopyWith<$Res> {
  __$$ExtractedDispoImplCopyWithImpl(
    _$ExtractedDispoImpl _value,
    $Res Function(_$ExtractedDispoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? fields = null,
    Object? confidence = null,
    Object? sourceUtterance = null,
    Object? sourceTranscriptIds = null,
    Object? extractedAt = null,
    Object? eventTime = null,
  }) {
    return _then(
      _$ExtractedDispoImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        fields: null == fields
            ? _value.fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as DispoFields,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        sourceUtterance: null == sourceUtterance
            ? _value.sourceUtterance
            : sourceUtterance // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceTranscriptIds: null == sourceTranscriptIds
            ? _value._sourceTranscriptIds
            : sourceTranscriptIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        extractedAt: null == extractedAt
            ? _value.extractedAt
            : extractedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventTime: null == eventTime
            ? _value.eventTime
            : eventTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DispoFieldsCopyWith<$Res> get fields {
    return $DispoFieldsCopyWith<$Res>(_value.fields, (value) {
      return _then(_value.copyWith(fields: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractedDispoImpl implements ExtractedDispo {
  const _$ExtractedDispoImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.fields,
    required this.confidence,
    @JsonKey(name: 'source_utterance') required this.sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required this.extractedAt,
    @JsonKey(name: 'event_time') required this.eventTime,
    final String? $type,
  }) : _sourceTranscriptIds = sourceTranscriptIds,
       $type = $type ?? 'dispo';

  factory _$ExtractedDispoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractedDispoImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final DispoFields fields;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'source_utterance')
  final String sourceUtterance;
  final List<String> _sourceTranscriptIds;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds {
    if (_sourceTranscriptIds is EqualUnmodifiableListView)
      return _sourceTranscriptIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceTranscriptIds);
  }

  @override
  @JsonKey(name: 'extracted_at')
  final DateTime extractedAt;
  @override
  @JsonKey(name: 'event_time')
  final DateTime eventTime;

  @JsonKey(name: 'event_type')
  final String $type;

  @override
  String toString() {
    return 'ExtractedEvent.dispo(eventId: $eventId, fields: $fields, confidence: $confidence, sourceUtterance: $sourceUtterance, sourceTranscriptIds: $sourceTranscriptIds, extractedAt: $extractedAt, eventTime: $eventTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractedDispoImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.fields, fields) || other.fields == fields) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sourceUtterance, sourceUtterance) ||
                other.sourceUtterance == sourceUtterance) &&
            const DeepCollectionEquality().equals(
              other._sourceTranscriptIds,
              _sourceTranscriptIds,
            ) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    fields,
    confidence,
    sourceUtterance,
    const DeepCollectionEquality().hash(_sourceTranscriptIds),
    extractedAt,
    eventTime,
  );

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractedDispoImplCopyWith<_$ExtractedDispoImpl> get copyWith =>
      __$$ExtractedDispoImplCopyWithImpl<_$ExtractedDispoImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    vitalSign,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    medicationAdministered,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    dispo,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    note,
  }) {
    return dispo(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
  }) {
    return dispo?.call(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
    required TResult orElse(),
  }) {
    if (dispo != null) {
      return dispo(
        eventId,
        fields,
        confidence,
        sourceUtterance,
        sourceTranscriptIds,
        extractedAt,
        eventTime,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExtractedVitalSign value) vitalSign,
    required TResult Function(ExtractedMedicationAdministered value)
    medicationAdministered,
    required TResult Function(ExtractedDispo value) dispo,
    required TResult Function(ExtractedNote value) note,
  }) {
    return dispo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExtractedVitalSign value)? vitalSign,
    TResult? Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult? Function(ExtractedDispo value)? dispo,
    TResult? Function(ExtractedNote value)? note,
  }) {
    return dispo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExtractedVitalSign value)? vitalSign,
    TResult Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult Function(ExtractedDispo value)? dispo,
    TResult Function(ExtractedNote value)? note,
    required TResult orElse(),
  }) {
    if (dispo != null) {
      return dispo(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractedDispoImplToJson(this);
  }
}

abstract class ExtractedDispo implements ExtractedEvent {
  const factory ExtractedDispo({
    @JsonKey(name: 'event_id') required final String eventId,
    required final DispoFields fields,
    required final double confidence,
    @JsonKey(name: 'source_utterance') required final String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required final DateTime extractedAt,
    @JsonKey(name: 'event_time') required final DateTime eventTime,
  }) = _$ExtractedDispoImpl;

  factory ExtractedDispo.fromJson(Map<String, dynamic> json) =
      _$ExtractedDispoImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  DispoFields get fields;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'source_utterance')
  String get sourceUtterance;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds;
  @override
  @JsonKey(name: 'extracted_at')
  DateTime get extractedAt;
  @override
  @JsonKey(name: 'event_time')
  DateTime get eventTime;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractedDispoImplCopyWith<_$ExtractedDispoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExtractedNoteImplCopyWith<$Res>
    implements $ExtractedEventCopyWith<$Res> {
  factory _$$ExtractedNoteImplCopyWith(
    _$ExtractedNoteImpl value,
    $Res Function(_$ExtractedNoteImpl) then,
  ) = __$$ExtractedNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    NoteFields fields,
    double confidence,
    @JsonKey(name: 'source_utterance') String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') DateTime extractedAt,
    @JsonKey(name: 'event_time') DateTime eventTime,
  });

  $NoteFieldsCopyWith<$Res> get fields;
}

/// @nodoc
class __$$ExtractedNoteImplCopyWithImpl<$Res>
    extends _$ExtractedEventCopyWithImpl<$Res, _$ExtractedNoteImpl>
    implements _$$ExtractedNoteImplCopyWith<$Res> {
  __$$ExtractedNoteImplCopyWithImpl(
    _$ExtractedNoteImpl _value,
    $Res Function(_$ExtractedNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? fields = null,
    Object? confidence = null,
    Object? sourceUtterance = null,
    Object? sourceTranscriptIds = null,
    Object? extractedAt = null,
    Object? eventTime = null,
  }) {
    return _then(
      _$ExtractedNoteImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        fields: null == fields
            ? _value.fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as NoteFields,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        sourceUtterance: null == sourceUtterance
            ? _value.sourceUtterance
            : sourceUtterance // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceTranscriptIds: null == sourceTranscriptIds
            ? _value._sourceTranscriptIds
            : sourceTranscriptIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        extractedAt: null == extractedAt
            ? _value.extractedAt
            : extractedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventTime: null == eventTime
            ? _value.eventTime
            : eventTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NoteFieldsCopyWith<$Res> get fields {
    return $NoteFieldsCopyWith<$Res>(_value.fields, (value) {
      return _then(_value.copyWith(fields: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractedNoteImpl implements ExtractedNote {
  const _$ExtractedNoteImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    required this.fields,
    required this.confidence,
    @JsonKey(name: 'source_utterance') required this.sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required this.extractedAt,
    @JsonKey(name: 'event_time') required this.eventTime,
    final String? $type,
  }) : _sourceTranscriptIds = sourceTranscriptIds,
       $type = $type ?? 'note';

  factory _$ExtractedNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractedNoteImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  final NoteFields fields;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'source_utterance')
  final String sourceUtterance;
  final List<String> _sourceTranscriptIds;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds {
    if (_sourceTranscriptIds is EqualUnmodifiableListView)
      return _sourceTranscriptIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceTranscriptIds);
  }

  @override
  @JsonKey(name: 'extracted_at')
  final DateTime extractedAt;
  @override
  @JsonKey(name: 'event_time')
  final DateTime eventTime;

  @JsonKey(name: 'event_type')
  final String $type;

  @override
  String toString() {
    return 'ExtractedEvent.note(eventId: $eventId, fields: $fields, confidence: $confidence, sourceUtterance: $sourceUtterance, sourceTranscriptIds: $sourceTranscriptIds, extractedAt: $extractedAt, eventTime: $eventTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractedNoteImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.fields, fields) || other.fields == fields) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sourceUtterance, sourceUtterance) ||
                other.sourceUtterance == sourceUtterance) &&
            const DeepCollectionEquality().equals(
              other._sourceTranscriptIds,
              _sourceTranscriptIds,
            ) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    fields,
    confidence,
    sourceUtterance,
    const DeepCollectionEquality().hash(_sourceTranscriptIds),
    extractedAt,
    eventTime,
  );

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractedNoteImplCopyWith<_$ExtractedNoteImpl> get copyWith =>
      __$$ExtractedNoteImplCopyWithImpl<_$ExtractedNoteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    vitalSign,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    medicationAdministered,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    dispo,
    required TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )
    note,
  }) {
    return note(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult? Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
  }) {
    return note?.call(
      eventId,
      fields,
      confidence,
      sourceUtterance,
      sourceTranscriptIds,
      extractedAt,
      eventTime,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      VitalSignFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    vitalSign,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      MedicationAdministeredFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    medicationAdministered,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      DispoFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    dispo,
    TResult Function(
      @JsonKey(name: 'event_id') String eventId,
      NoteFields fields,
      double confidence,
      @JsonKey(name: 'source_utterance') String sourceUtterance,
      @JsonKey(name: 'source_transcript_ids') List<String> sourceTranscriptIds,
      @JsonKey(name: 'extracted_at') DateTime extractedAt,
      @JsonKey(name: 'event_time') DateTime eventTime,
    )?
    note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(
        eventId,
        fields,
        confidence,
        sourceUtterance,
        sourceTranscriptIds,
        extractedAt,
        eventTime,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExtractedVitalSign value) vitalSign,
    required TResult Function(ExtractedMedicationAdministered value)
    medicationAdministered,
    required TResult Function(ExtractedDispo value) dispo,
    required TResult Function(ExtractedNote value) note,
  }) {
    return note(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExtractedVitalSign value)? vitalSign,
    TResult? Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult? Function(ExtractedDispo value)? dispo,
    TResult? Function(ExtractedNote value)? note,
  }) {
    return note?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExtractedVitalSign value)? vitalSign,
    TResult Function(ExtractedMedicationAdministered value)?
    medicationAdministered,
    TResult Function(ExtractedDispo value)? dispo,
    TResult Function(ExtractedNote value)? note,
    required TResult orElse(),
  }) {
    if (note != null) {
      return note(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractedNoteImplToJson(this);
  }
}

abstract class ExtractedNote implements ExtractedEvent {
  const factory ExtractedNote({
    @JsonKey(name: 'event_id') required final String eventId,
    required final NoteFields fields,
    required final double confidence,
    @JsonKey(name: 'source_utterance') required final String sourceUtterance,
    @JsonKey(name: 'source_transcript_ids')
    required final List<String> sourceTranscriptIds,
    @JsonKey(name: 'extracted_at') required final DateTime extractedAt,
    @JsonKey(name: 'event_time') required final DateTime eventTime,
  }) = _$ExtractedNoteImpl;

  factory ExtractedNote.fromJson(Map<String, dynamic> json) =
      _$ExtractedNoteImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  NoteFields get fields;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'source_utterance')
  String get sourceUtterance;
  @override
  @JsonKey(name: 'source_transcript_ids')
  List<String> get sourceTranscriptIds;
  @override
  @JsonKey(name: 'extracted_at')
  DateTime get extractedAt;
  @override
  @JsonKey(name: 'event_time')
  DateTime get eventTime;

  /// Create a copy of ExtractedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractedNoteImplCopyWith<_$ExtractedNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
