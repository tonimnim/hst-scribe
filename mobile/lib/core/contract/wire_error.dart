import 'package:freezed_annotation/freezed_annotation.dart';

part 'wire_error.freezed.dart';
part 'wire_error.g.dart';

/// Wire-error envelope used in REST responses and WSS `error` payloads.
/// Shape: `{ "code": "...", "message": "...", "details": {...} }`.
@freezed
class WireError with _$WireError {
  const factory WireError({
    required String code,
    required String message,
    @JsonKey(name: 'details') Map<String, Object?>? details,
  }) = _WireError;

  factory WireError.fromJson(Map<String, Object?> json) =>
      _$WireErrorFromJson(json);
}
