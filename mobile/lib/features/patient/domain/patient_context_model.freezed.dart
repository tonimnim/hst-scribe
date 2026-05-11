// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_context_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PatientContextModel {
  String get patientId => throw _privateConstructorUsedError;
  String get displayNameInitials => throw _privateConstructorUsedError;
  String get mrnLast4 => throw _privateConstructorUsedError;
  String get procedure => throw _privateConstructorUsedError;
  List<MedicationSummaryModel> get currentMedications =>
      throw _privateConstructorUsedError;
  List<AllergyModel> get allergies => throw _privateConstructorUsedError;
  List<String> get comorbidities => throw _privateConstructorUsedError;

  /// Create a copy of PatientContextModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientContextModelCopyWith<PatientContextModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientContextModelCopyWith<$Res> {
  factory $PatientContextModelCopyWith(
    PatientContextModel value,
    $Res Function(PatientContextModel) then,
  ) = _$PatientContextModelCopyWithImpl<$Res, PatientContextModel>;
  @useResult
  $Res call({
    String patientId,
    String displayNameInitials,
    String mrnLast4,
    String procedure,
    List<MedicationSummaryModel> currentMedications,
    List<AllergyModel> allergies,
    List<String> comorbidities,
  });
}

/// @nodoc
class _$PatientContextModelCopyWithImpl<$Res, $Val extends PatientContextModel>
    implements $PatientContextModelCopyWith<$Res> {
  _$PatientContextModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientContextModel
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
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String,
            displayNameInitials: null == displayNameInitials
                ? _value.displayNameInitials
                : displayNameInitials // ignore: cast_nullable_to_non_nullable
                      as String,
            mrnLast4: null == mrnLast4
                ? _value.mrnLast4
                : mrnLast4 // ignore: cast_nullable_to_non_nullable
                      as String,
            procedure: null == procedure
                ? _value.procedure
                : procedure // ignore: cast_nullable_to_non_nullable
                      as String,
            currentMedications: null == currentMedications
                ? _value.currentMedications
                : currentMedications // ignore: cast_nullable_to_non_nullable
                      as List<MedicationSummaryModel>,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<AllergyModel>,
            comorbidities: null == comorbidities
                ? _value.comorbidities
                : comorbidities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PatientContextModelImplCopyWith<$Res>
    implements $PatientContextModelCopyWith<$Res> {
  factory _$$PatientContextModelImplCopyWith(
    _$PatientContextModelImpl value,
    $Res Function(_$PatientContextModelImpl) then,
  ) = __$$PatientContextModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String patientId,
    String displayNameInitials,
    String mrnLast4,
    String procedure,
    List<MedicationSummaryModel> currentMedications,
    List<AllergyModel> allergies,
    List<String> comorbidities,
  });
}

/// @nodoc
class __$$PatientContextModelImplCopyWithImpl<$Res>
    extends _$PatientContextModelCopyWithImpl<$Res, _$PatientContextModelImpl>
    implements _$$PatientContextModelImplCopyWith<$Res> {
  __$$PatientContextModelImplCopyWithImpl(
    _$PatientContextModelImpl _value,
    $Res Function(_$PatientContextModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientContextModel
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
      _$PatientContextModelImpl(
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayNameInitials: null == displayNameInitials
            ? _value.displayNameInitials
            : displayNameInitials // ignore: cast_nullable_to_non_nullable
                  as String,
        mrnLast4: null == mrnLast4
            ? _value.mrnLast4
            : mrnLast4 // ignore: cast_nullable_to_non_nullable
                  as String,
        procedure: null == procedure
            ? _value.procedure
            : procedure // ignore: cast_nullable_to_non_nullable
                  as String,
        currentMedications: null == currentMedications
            ? _value._currentMedications
            : currentMedications // ignore: cast_nullable_to_non_nullable
                  as List<MedicationSummaryModel>,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<AllergyModel>,
        comorbidities: null == comorbidities
            ? _value._comorbidities
            : comorbidities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$PatientContextModelImpl extends _PatientContextModel {
  const _$PatientContextModelImpl({
    required this.patientId,
    required this.displayNameInitials,
    required this.mrnLast4,
    required this.procedure,
    final List<MedicationSummaryModel> currentMedications =
        const <MedicationSummaryModel>[],
    final List<AllergyModel> allergies = const <AllergyModel>[],
    final List<String> comorbidities = const <String>[],
  }) : _currentMedications = currentMedications,
       _allergies = allergies,
       _comorbidities = comorbidities,
       super._();

  @override
  final String patientId;
  @override
  final String displayNameInitials;
  @override
  final String mrnLast4;
  @override
  final String procedure;
  final List<MedicationSummaryModel> _currentMedications;
  @override
  @JsonKey()
  List<MedicationSummaryModel> get currentMedications {
    if (_currentMedications is EqualUnmodifiableListView)
      return _currentMedications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentMedications);
  }

  final List<AllergyModel> _allergies;
  @override
  @JsonKey()
  List<AllergyModel> get allergies {
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
    return 'PatientContextModel(patientId: $patientId, displayNameInitials: $displayNameInitials, mrnLast4: $mrnLast4, procedure: $procedure, currentMedications: $currentMedications, allergies: $allergies, comorbidities: $comorbidities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientContextModelImpl &&
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

  /// Create a copy of PatientContextModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientContextModelImplCopyWith<_$PatientContextModelImpl> get copyWith =>
      __$$PatientContextModelImplCopyWithImpl<_$PatientContextModelImpl>(
        this,
        _$identity,
      );
}

abstract class _PatientContextModel extends PatientContextModel {
  const factory _PatientContextModel({
    required final String patientId,
    required final String displayNameInitials,
    required final String mrnLast4,
    required final String procedure,
    final List<MedicationSummaryModel> currentMedications,
    final List<AllergyModel> allergies,
    final List<String> comorbidities,
  }) = _$PatientContextModelImpl;
  const _PatientContextModel._() : super._();

  @override
  String get patientId;
  @override
  String get displayNameInitials;
  @override
  String get mrnLast4;
  @override
  String get procedure;
  @override
  List<MedicationSummaryModel> get currentMedications;
  @override
  List<AllergyModel> get allergies;
  @override
  List<String> get comorbidities;

  /// Create a copy of PatientContextModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientContextModelImplCopyWith<_$PatientContextModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MedicationSummaryModel {
  String get rxnormCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get dose => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;

  /// Create a copy of MedicationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationSummaryModelCopyWith<MedicationSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationSummaryModelCopyWith<$Res> {
  factory $MedicationSummaryModelCopyWith(
    MedicationSummaryModel value,
    $Res Function(MedicationSummaryModel) then,
  ) = _$MedicationSummaryModelCopyWithImpl<$Res, MedicationSummaryModel>;
  @useResult
  $Res call({String rxnormCode, String name, String dose, String route});
}

/// @nodoc
class _$MedicationSummaryModelCopyWithImpl<
  $Res,
  $Val extends MedicationSummaryModel
>
    implements $MedicationSummaryModelCopyWith<$Res> {
  _$MedicationSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicationSummaryModel
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
            rxnormCode: null == rxnormCode
                ? _value.rxnormCode
                : rxnormCode // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dose: null == dose
                ? _value.dose
                : dose // ignore: cast_nullable_to_non_nullable
                      as String,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicationSummaryModelImplCopyWith<$Res>
    implements $MedicationSummaryModelCopyWith<$Res> {
  factory _$$MedicationSummaryModelImplCopyWith(
    _$MedicationSummaryModelImpl value,
    $Res Function(_$MedicationSummaryModelImpl) then,
  ) = __$$MedicationSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rxnormCode, String name, String dose, String route});
}

/// @nodoc
class __$$MedicationSummaryModelImplCopyWithImpl<$Res>
    extends
        _$MedicationSummaryModelCopyWithImpl<$Res, _$MedicationSummaryModelImpl>
    implements _$$MedicationSummaryModelImplCopyWith<$Res> {
  __$$MedicationSummaryModelImplCopyWithImpl(
    _$MedicationSummaryModelImpl _value,
    $Res Function(_$MedicationSummaryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicationSummaryModel
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
      _$MedicationSummaryModelImpl(
        rxnormCode: null == rxnormCode
            ? _value.rxnormCode
            : rxnormCode // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dose: null == dose
            ? _value.dose
            : dose // ignore: cast_nullable_to_non_nullable
                  as String,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MedicationSummaryModelImpl implements _MedicationSummaryModel {
  const _$MedicationSummaryModelImpl({
    required this.rxnormCode,
    required this.name,
    required this.dose,
    required this.route,
  });

  @override
  final String rxnormCode;
  @override
  final String name;
  @override
  final String dose;
  @override
  final String route;

  @override
  String toString() {
    return 'MedicationSummaryModel(rxnormCode: $rxnormCode, name: $name, dose: $dose, route: $route)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationSummaryModelImpl &&
            (identical(other.rxnormCode, rxnormCode) ||
                other.rxnormCode == rxnormCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dose, dose) || other.dose == dose) &&
            (identical(other.route, route) || other.route == route));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rxnormCode, name, dose, route);

  /// Create a copy of MedicationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationSummaryModelImplCopyWith<_$MedicationSummaryModelImpl>
  get copyWith =>
      __$$MedicationSummaryModelImplCopyWithImpl<_$MedicationSummaryModelImpl>(
        this,
        _$identity,
      );
}

abstract class _MedicationSummaryModel implements MedicationSummaryModel {
  const factory _MedicationSummaryModel({
    required final String rxnormCode,
    required final String name,
    required final String dose,
    required final String route,
  }) = _$MedicationSummaryModelImpl;

  @override
  String get rxnormCode;
  @override
  String get name;
  @override
  String get dose;
  @override
  String get route;

  /// Create a copy of MedicationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationSummaryModelImplCopyWith<_$MedicationSummaryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AllergyModel {
  String get name => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;

  /// Create a copy of AllergyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergyModelCopyWith<AllergyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergyModelCopyWith<$Res> {
  factory $AllergyModelCopyWith(
    AllergyModel value,
    $Res Function(AllergyModel) then,
  ) = _$AllergyModelCopyWithImpl<$Res, AllergyModel>;
  @useResult
  $Res call({String name, String severity});
}

/// @nodoc
class _$AllergyModelCopyWithImpl<$Res, $Val extends AllergyModel>
    implements $AllergyModelCopyWith<$Res> {
  _$AllergyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllergyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? severity = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AllergyModelImplCopyWith<$Res>
    implements $AllergyModelCopyWith<$Res> {
  factory _$$AllergyModelImplCopyWith(
    _$AllergyModelImpl value,
    $Res Function(_$AllergyModelImpl) then,
  ) = __$$AllergyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String severity});
}

/// @nodoc
class __$$AllergyModelImplCopyWithImpl<$Res>
    extends _$AllergyModelCopyWithImpl<$Res, _$AllergyModelImpl>
    implements _$$AllergyModelImplCopyWith<$Res> {
  __$$AllergyModelImplCopyWithImpl(
    _$AllergyModelImpl _value,
    $Res Function(_$AllergyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AllergyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? severity = null}) {
    return _then(
      _$AllergyModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AllergyModelImpl implements _AllergyModel {
  const _$AllergyModelImpl({required this.name, required this.severity});

  @override
  final String name;
  @override
  final String severity;

  @override
  String toString() {
    return 'AllergyModel(name: $name, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergyModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.severity, severity) ||
                other.severity == severity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, severity);

  /// Create a copy of AllergyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergyModelImplCopyWith<_$AllergyModelImpl> get copyWith =>
      __$$AllergyModelImplCopyWithImpl<_$AllergyModelImpl>(this, _$identity);
}

abstract class _AllergyModel implements AllergyModel {
  const factory _AllergyModel({
    required final String name,
    required final String severity,
  }) = _$AllergyModelImpl;

  @override
  String get name;
  @override
  String get severity;

  /// Create a copy of AllergyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergyModelImplCopyWith<_$AllergyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
