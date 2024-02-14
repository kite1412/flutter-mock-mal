// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_media_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMediaStatus _$UserMediaStatusFromJson(Map<String, dynamic> json) =>
    UserMediaStatus(
      json['score'] as int,
      json['updated_at'] as String,
    )
      ..status = json['status'] as String?
      ..numEpisodesWatched = json['num_episodes_watched'] as int?
      ..isRewatching = json['is_rewatching'] as bool?
      ..startDate = json['start_date'] as String?
      ..finishDate = json['finish_date'] as String?
      ..priority = json['priority'] as int?
      ..numTimesRewatched = json['num_times_rewatched'] as int?
      ..rewatchValue = json['rewatch_value'] as int?
      ..tags =
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..comments = json['comments'] as String?
      ..isRereading = json['is_rereading'] as bool?
      ..numVolumesRead = json['num_volumes_read'] as int?
      ..numChaptersRead = json['num_chapters_read'] as int?;

Map<String, dynamic> _$UserMediaStatusToJson(UserMediaStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'score': instance.score,
      'num_episodes_watched': instance.numEpisodesWatched,
      'is_rewatching': instance.isRewatching,
      'start_date': instance.startDate,
      'finish_date': instance.finishDate,
      'priority': instance.priority,
      'num_times_rewatched': instance.numTimesRewatched,
      'rewatch_value': instance.rewatchValue,
      'tags': instance.tags,
      'comments': instance.comments,
      'updated_at': instance.updatedAt,
      'is_rereading': instance.isRereading,
      'num_volumes_read': instance.numVolumesRead,
      'num_chapters_read': instance.numChaptersRead,
    };
