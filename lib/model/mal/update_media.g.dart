// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMedia _$UpdateMediaFromJson(Map<String, dynamic> json) => UpdateMedia()
  ..status = json['status'] as String?
  ..score = json['score'] as int?
  ..isRewatching = json['isRewatching'] as bool?
  ..numEpisodesWatched = json['num_episodes_watched'] as int?
  ..priority = json['priority'] as int?
  ..numTimesRewatched = json['num_times_rewatched'] as int?
  ..rewatchValue = json['rewatch_value'] as int?
  ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..comments = json['comments'] as String?
  ..startDate = json['start_date'] as String?
  ..finishDate = json['finish_date'] as String?
  ..updatedAt = json['updated_at'] as String?
  ..numChaptersRead = json['num_chapters_read'] as int?;

Map<String, dynamic> _$UpdateMediaToJson(UpdateMedia instance) =>
    <String, dynamic>{
      'status': instance.status,
      'score': instance.score,
      'isRewatching': instance.isRewatching,
      'num_episodes_watched': instance.numEpisodesWatched,
      'priority': instance.priority,
      'num_times_rewatched': instance.numTimesRewatched,
      'rewatch_value': instance.rewatchValue,
      'tags': instance.tags,
      'comments': instance.comments,
      'start_date': instance.startDate,
      'finish_date': instance.finishDate,
      'updated_at': instance.updatedAt,
      'num_chapters_read': instance.numChaptersRead,
    };
