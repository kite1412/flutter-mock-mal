// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) => Resource()
  ..malId = json['mal_id'] as int?
  ..type = json['type'] as String?
  ..name = json['name'] as String?
  ..url = json['url'] as String?;

Map<String, dynamic> _$ResourceToJson(Resource instance) => <String, dynamic>{
      'mal_id': instance.malId,
      'type': instance.type,
      'name': instance.name,
      'url': instance.url,
    };
