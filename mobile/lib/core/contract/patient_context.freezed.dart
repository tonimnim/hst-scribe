// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicationSummary _$MedicationSummaryFromJson(Map<String, dynamic> json) {
  return _MedicationSummary.fromJson(json);
}

/// @nodoc
mixin _$MedicationSummary {
  @JsonKey(name: 'rxnorm_code')
  String get rxnormCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get dose => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;

  /// Serializes this MedicationSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationSummaryCopyWith<MedicationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationSummaryCopyWith<$Res> {
  factory $MedicationSummaryCopyWith(
    MedicationSummary value,
    $Res Function(MedicationSummary) then,
  ) = _$MedicationSummaryCopyWithImpl<$Res, MedicationSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'rxnorm_code') String rxnormCode,
    String name,
    String dose,
    String route,
  });
}

/// @nodoc
class _$MedicationSummaryCopyWithImpl<$Res, $Val extends MedicationSummary>
    implements $MedicationSummaryCopyWith<$Res> {
  _$MedicationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rxnormCode = null,
    Object? name = null,
    Object? dose = null,
    Object? route = null,
  }) {
    return _then(
      _value.copyWith(
            rxnormCode:
                null == rxnormCode
                    ? _value.rxnormCode
                    : rxnormCode // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            dose:
                null == dose
                    ? _value.dose
                    : dose // ignore: cast_nullable_to_non_nullable
                        as String,
            route:
                null == route
                    ? _value.route
                    : route // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicationSummaryImplCopyWith<$Res>
    implements $MedicationSummaryCopyWith<$Res> {
  factory _$$MedicationSummaryImplCopyWith(
    _$MedicationSummaryImpl value,
    $Res Function(_$MedicationSummaryImpl) then,
  ) = __$$MedicationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'rxnorm_code') String rxnormCode,
    String name,
    String dose,
    String route,
  });
}

/// @nodoc
class __$$MedicationSummaryImplCopyWithImpl<$Res>
    extends _$MedicationSummaryCopyWithImpl<$Res, _$MedicationSummaryImpl>
    implements _$$MedicationSummaryImplCopyWith<$Res> {
  __$$MedicationSummaryImplCopyWithImpl(
    _$MedicationSummaryImpl _value,
    $Res Function(_$MedicationSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rxnormCode = null,
    Object? name = null,
    Object? dose = null,
    Object? route = null,
  }) {
    return _then(
      _$MedicationSummaryImpl(
        rxnormCode:
            null == rxnormCode
                ? _value.rxnormCode
                : rxnormCode // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        dose:
            null == dose
                ? _value.dose
                : dose // ignore: cast_nullable_to_non_nullable
                    as String,
        route:
            null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationSummaryImpl implements _MedicationSummary {
  const _$MedicationSummaryImpl({
    @JsonKey(name: 'rxnorm_code') required this.rxnormCode,
    required this.name,
    required this.dose,
    required this.route,
  });

  factory _$MedicationSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'rxnorm_code')
  final String rxnormCode;
  @override
  final String name;
  @override
  final String dose;
  @override
  final String route;

  @override
  String toString() {
    return 'MedicationSummary(rxnormCode: $rxnormCode, name: $name, dose: $dose, route: $route)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationSummaryImpl &&
            (identical(other.rxnormCode, rxnormCode) ||
                other.rxnormCode == rxnormCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dose, dose) || other.dose == dose) &&
            (identical(other.route, route) || other.route == route));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rxnormCode, name, dose, route);

  /// Create a copy of MedicationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationSummaryImplCopyWith<_$MedicationSummaryImpl> get copyWith =>
      __$$MedicationSummaryImplCopyWithImpl<_$MedicationSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationSummaryImplToJson(this);
  }
}

abstract class _MedicationSummary implements MedicationSummary {
  const factory _MedicationSummary({
    @JsonKey(name: 'rxnorm_code') required final String rxnormCode,
    required final String name,
    required final String dose,
    required final String route,
  }) = _$MedicationSummaryImpl;

  factory _MedicationSummary.fromJson(Map<String, dynamic> json) =
      _$MedicationSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'rxnorm_code')
  String get rxnormCode;
  @override
  String get name;
  @override
  String get dose;
  @override
  String get route;

  /// Create a copy of MedicationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationSummaryImplCopyWith<_$MedicationSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AllergySummary _$AllergySummaryFromJson(Map<String, dynamic> json) {
  return _AllergySummary.fromJson(json);
}

/// @nodoc
mixin _$AllergySummary {
  String get name => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;

  /// Serializes this AllergySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AllergySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergySummaryCopyWith<AllergySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergySummaryCopyWith<$Res> {
  factory $AllergySummaryCopyWith(
    AllergySummary value,
    $Res Function(AllergySummary) then,
  ) = _$AllergySummaryCopyWithImpl<$Res, AllergySummary>;
  @useResult
  $Res call({String name, String severity});
}

/// @nodoc
class _$AllergySummaryCopyWithImpl<$Res, $Val extends AllergySummary>
    implements $AllergySummaryCopyWith<$Res> {
  _$AllergySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? severity = null}) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergySummaryImplCopyWith<$Res>
    implements $AllergySummaryCopyWith<$Res> {
  factory _$$AllergySummaryImplCopyWith(
    _$AllergySummaryImpl value,
    $Res Function(_$AllergySummaryImpl) then,
  ) = __$$AllergySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String severity});
}

/// @nodoc
class __$$AllergySummaryImplCopyWithImpl<$Res>
    extends _$AllergySummaryCopyWithImpl<$Res, _$AllergySummaryImpl>
    implements _$$AllergySummaryImplCopyWith<$Res> {
  __$$AllergySummaryImplCopyWithImpl(
    _$AllergySummaryImpl _value,
    $Res Function(_$AllergySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? severity = null}) {
    return _then(
      _$AllergySummaryImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AllergySummaryImpl implements _AllergySummary {
  const _$AllergySummaryImpl({required this.name, required this.severity});

  factory _$AllergySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllergySummaryImplFromJson(json);

  @override
  final String name;
  @override
  final String severity;

  @override
  String toString() {
    return 'AllergySummary(name: $name, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergySummaryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, severity);

  /// Create a copy of AllergySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergySummaryImplCopyWith<_$AllergySummaryImpl> get copyWith =>
      __$$AllergySummaryImplCopyWithImpl<_$AllergySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AllergySummaryImplToJson(this);
  }
}

abstract class _AllergySummary implements AllergySummary {
  const factory _AllergySummary({
    required final String name,
    required final String severity,
  }) = _$AllergySummaryImpl;

  factory _AllergySummary.fromJson(Map<String, dynamic> json) =
      _$AllergySummaryImpl.fromJson;

  @override
  String get name;
  @override
  String get severity;

  /// Create a copy of AllergySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergySummaryImplCopyWith<_$AllergySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientContext _$PatientContextFromJson(Map<String, dynamic> json) {
  return _PatientContext.fromJson(json);
}

/// @nodoc
mixin _$PatientContext {
  @JsonKey(name: 'patient_id')
  String get patientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name_initials')
  String get displayNameInitials => throw _privateConstructorUsedError;
  @JsonKey(name: 'mrn_last4')
  String get mrnLast4 => throw _privateConstructorUsedError;
  String get procedure => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_medications')
  List<MedicationSummary> get currentMedications =>
      throw _privateConstructorUsedError;
  List<AllergySummary> get allergies => throw _privateConstructorUsedError;
  List<String> get comorbidities => throw _privateConstructorUsedError;

  /// Serializes this PatientContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientContextCopyWith<PatientContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientContextCopyWith<$Res> {
  factory $PatientContextCopyWith(
    PatientContext value,
    $Res Function(PatientContext) then,
  ) = _$PatientContextCopyWithImpl<$Res, PatientContext>;
  @useResult
  $Res call({
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'display_name_initials') String displayNameInitials,
    @JsonKey(name: 'mrn_last4') String mrnLast4,
    String procedure,
    @JsonKey(name: 'current_medications')
    List<MedicationSummary> currentMedications,
    List<AllergySummary> allergies,
    List<String> comorbidities,
  });
}

/// @nodoc
class _$PatientContextCopyWithImpl<$Res, $Val extends PatientContext>
    implements $PatientContextCopyWith<$Res> {
  _$PatientContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? displayNameInitials = null,
    Object? mrnLast4 = null,
    Object? procedure = null,
    Object? currentMedications = null,
    Object? allergies = null,
    Object? comorbidities = null,
  }) {
    return _then(
      _value.copyWith(
            patientId:
                null == patientId
                    ? _value.patientId
                    : patientId // ignore: cast_nullable_to_non_nullable
                        as String,
            displayNameInitials:
                null == displayNameInitials
                    ? _value.displayNameInitials
                    : displayNameInitials // ignore: cast_nullable_to_non_nullable
                        as String,
            mrnLast4:
                null == mrnLast4
                    ? _value.mrnLast4
                    : mrnLast4 // ignore: cast_nullable_to_non_nullable
                        as String,
            procedure:
                null == procedure
                    ? _value.procedure
                    : procedure // ignore: cast_nullable_to_non_nullable
                        as String,
            currentMedications:
                null == currentMedications
                    ? _value.currentMedications
                    : currentMedications // ignore: cast_nullable_to_non_nullable
                        as List<MedicationSummary>,
            allergies:
                null == allergies
                    ? _value.allergies
                    : allergies // ignore: cast_nullable_to_non_nullable
                        as List<AllergySummary>,
            comorbidities:
                null == comorbidities
                    ? _value.comorbidities
                    : comorbidities // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PatientContextImplCopyWith<$Res>
    implements $PatientContextCopyWith<$Res> {
  factory _$$PatientContextImplCopyWith(
    _$PatientContextImpl value,
    $Res Function(_$PatientContextImpl) then,
  ) = __$$PatientContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'patient_id') String patientId,
    @JsonKey(name: 'display_name_initials') String displayNameInitials,
    @JsonKey(name: 'mrn_last4') String mrnLast4,
    String procedure,
    @JsonKey(name: 'current_medications')
    List<MedicationSummary> currentMedications,
    List<AllergySummary> allergies,
    List<String> comorbidities,
  });
}

/// @nodoc
class __$$PatientContextImplCopyWithImpl<$Res>
    extends _$PatientContextCopyWithImpl<$Res, _$PatientContextImpl>
    implements _$$PatientContextImplCopyWith<$Res> {
  __$$PatientContextImplCopyWithImpl(
    _$PatientContextImpl _value,
    $Res Function(_$PatientContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? displayNameInitials = null,
    Object? mrnLast4 = null,
    Object? procedure = null,
    Object? currentMedications = null,
    Object? allergies = null,
    Object? comorbidities = null,
  }) {
    return _then(
      _$PatientContextImpl(
        patientId:
            null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                    as String,
        displayNameInitials:
            null == displayNameInitials
                ? _value.displayNameInitials
                : displayNameInitials // ignore: cast_nullable_to_non_nullable
                    as String,
        mrnLast4:
            null == mrnLast4
                ? _value.mrnLast4
                : mrnLast4 // ignore: cast_nullable_to_non_nullable
                    as String,
        procedure:
            null == procedure
                ? _value.procedure
                : procedure // ignore: cast_nullable_to_non_nullable
                    as String,
        currentMedications:
            null == currentMedications
                ? _value._currentMedications
                : currentMedications // ignore: cast_nullable_to_non_nullable
                    as List<MedicationSummary>,
        allergies:
            null == allergies
                ? _value._allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                    as List<AllergySummary>,
        comorbidities:
            null == comorbidities
                ? _value._comorbidities
                : comorbidities // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientContextImpl implements _PatientContext {
  const _$PatientContextImpl({
    @JsonKey(name: 'patient_id') required this.patientId,
    @JsonKey(name: 'display_name_initials') required this.displayNameInitials,
    @JsonKey(name: 'mrn_last4') required this.mrnLast4,
    required this.procedure,
    @JsonKey(name: 'current_medications')
    final List<MedicationSummary> currentMedications =
        const <MedicationSummary>[],
    final List<AllergySummary> allergies = const <AllergySummary>[],
    final List<String> comorbidities = const <String>[],
  }) : _currentMedications = currentMedications,
       _allergies = allergies,
       _comorbidities = comorbidities;

  factory _$PatientContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientContextImplFromJson(json);

  @override
  @JsonKey(name: 'patient_id')
  final String patientId;
  @override
  @JsonKey(name: 'display_name_initials')
  final String displayNameInitials;
  @override
  @JsonKey(name: 'mrn_last4')
  final String mrnLast4;
  @override
  final String procedure;
  final List<MedicationSummary> _currentMedications;
  @override
  @JsonKey(name: 'current_medications')
  List<MedicationSummary> get currentMedications {
    if (_currentMedications is EqualUnmodifiableListView)
      return _currentMedications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentMedications);
  }

  final List<AllergySummary> _allergies;
  @override
  @JsonKey()
  List<AllergySummary> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _comorbidities;
  @override
  @JsonKey()
  List<String> get comorbidities {
    if (_comorbidities is EqualUnmodifiableListView) return _comorbidities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comorbidities);
  }

  @override
  String toString() {
    return 'PatientContext(patientId: $patientId, displayNameInitials: $displayNameInitials, mrnLast4: $mrnLast4, procedure: $procedure, currentMedications: $currentMedications, allergies: $allergies, comorbidities: $comorbidities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientContextImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.displayNameInitials, displayNameInitials) ||
                other.displayNameInitials == displayNameInitials) &&
            (identical(other.mrnLast4, mrnLast4) ||
                other.mrnLast4 == mrnLast4) &&
            (identical(other.procedure, procedure) ||
                other.procedure == procedure) &&
            const DeepCollectionEquality().equals(
              other._currentMedications,
              _currentMedications,
            ) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._comorbidities,
              _comorbidities,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    patientId,
    displayNameInitials,
    mrnLast4,
    procedure,
    const DeepCollectionEquality().hash(_currentMedications),
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_comorbidities),
  );

  /// Create a copy of PatientContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientContextImplCopyWith<_$PatientContextImpl> get copyWith =>
      __$$PatientContextImplCopyWithImpl<_$PatientContextImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientContextImplToJson(this);
  }
}

abstract class _PatientContext implements PatientContext {
  const factory _PatientContext({
    @JsonKey(name: 'patient_id') required final String patientId,
    @JsonKey(name: 'display_name_initials')
    required final String displayNameInitials,
    @JsonKey(name: 'mrn_last4') required final String mrnLast4,
    required final String procedure,
    @JsonKey(name: 'current_medications')
    final List<MedicationSummary> currentMedications,
    final List<AllergySummary> allergies,
    final List<String> comorbidities,
  }) = _$PatientContextImpl;

  factory _PatientContext.fromJson(Map<String, dynamic> json) =
      _$PatientContextImpl.fromJson;

  @override
  @JsonKey(name: 'patient_id')
  String get patientId;
  @override
  @JsonKey(name: 'display_name_initials')
  String get displayNameInitials;
  @override
  @JsonKey(name: 'mrn_last4')
  String get mrnLast4;
  @override
  String get procedure;
  @override
  @JsonKey(name: 'current_medications')
  List<MedicationSummary> get currentMedications;
  @override
  List<AllergySummary> get allergies;
  @override
  List<String> get comorbidities;

  /// Create a copy of PatientContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientContextImplCopyWith<_$PatientContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
