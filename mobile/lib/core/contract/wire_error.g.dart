// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wire_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WireErrorImpl _$$WireErrorImplFromJson(Map<String, dynamic> json) =>
    _$WireErrorImpl(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WireErrorImplToJson(_$WireErrorImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'details': instance.details,
    };
