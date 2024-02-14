// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterInfo _$CharacterInfoFromJson(Map<String, dynamic> json) =>
    CharacterInfo()
      ..malId = json['mal_id'] as int?
      ..url = json['url'] as String?
      ..images = json['images'] == null
          ? null
          : Image.fromJson(json['images'] as Map<String, dynamic>)
      ..name = json['name'] as String?;

Map<String, dynamic> _$CharacterInfoToJson(CharacterInfo instance) =>
    <String, dynamic>{
      'mal_id': instance.malId,
      'url': instance.url,
      'images': instance.images,
      'name': instance.name,
    };
