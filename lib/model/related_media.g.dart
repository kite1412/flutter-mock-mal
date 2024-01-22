// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelatedMedia _$RelatedMediaFromJson(Map<String, dynamic> json) => RelatedMedia(
      (json['node'] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, MediaNode.fromJson(e as Map<String, dynamic>)),
              ))
          .toList(),
      json['relation_type'] as String,
      json['relation_type_formatted'] as String,
    );

Map<String, dynamic> _$RelatedMediaToJson(RelatedMedia instance) =>
    <String, dynamic>{
      'node': instance.relatedMedia,
      'relation_type': instance.relationType,
      'relation_type_formatted': instance.relationTypeFormatted,
    };
