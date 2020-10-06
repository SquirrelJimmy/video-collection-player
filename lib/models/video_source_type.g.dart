// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_source_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSourceType _$VideoSourceTypeFromJson(Map<String, dynamic> json) {
  return VideoSourceType()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..uri = json['uri'] as String
    ..httpsApi = json['httpsApi'] as String
    ..httpApi = json['httpApi'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$VideoSourceTypeToJson(VideoSourceType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uri': instance.uri,
      'httpsApi': instance.httpsApi,
      'httpApi': instance.httpApi,
      'type': instance.type,
    };
