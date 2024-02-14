// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person()
  ..malId = json['mal_id'] as int?
  ..url = json['url'] as String?
  ..images = json['images'] == null
      ? null
      : ImageFormat.fromJson(json['images'] as Map<String, dynamic>)
  ..name = json['name'] as String?;

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'mal_id': instance.malId,
      'url': instance.url,
      'images': instance.images,
      'name': instance.name,
    };
