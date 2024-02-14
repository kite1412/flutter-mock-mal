// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaNode _$MediaNodeFromJson(Map<String, dynamic> json) => MediaNode(
      json['id'] as int,
      json['title'] as String,
      MediaPicture.fromJson(json['main_picture'] as Map<String, dynamic>),
    )
      ..synopsis = json['synopsis'] as String?
      ..mean = (json['mean'] as num?)?.toDouble()
      ..mediaType = json['media_type'] as String?
      ..status = json['status'] as String?
      ..nsfw = json['nsfw'] as String?
      ..genres = (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList()
      ..pictures = (json['pictures'] as List<dynamic>?)
          ?.map((e) => MediaPicture.fromJson(e as Map<String, dynamic>))
          .toList()
      ..alternativeTitles = json['alternative_titles'] == null
          ? null
          : AlternativeTitles.fromJson(
              json['alternative_titles'] as Map<String, dynamic>)
      ..startDate = json['startDate'] as String?
      ..endDate = json['endDate'] as String?
      ..rank = json['rank'] as int?
      ..popularity = json['popularity'] as int?
      ..numListUsers = json['num_list_users'] as int?
      ..numScoringUsers = json['num_scoring_users'] as int?
      ..startSeason = json['start_season'] == null
          ? null
          : StartSeason.fromJson(json['start_season'] as Map<String, dynamic>)
      ..source = json['source'] as String?
      ..averageEpsDuration = json['average_episode_duration'] as int?
      ..rating = json['rating'] as String?
      ..studios = (json['studios'] as List<dynamic>?)
          ?.map((e) => Studio.fromJson(e as Map<String, dynamic>))
          .toList()
      ..userMediaStatus = json['my_list_status'] == null
          ? null
          : UserMediaStatus.fromJson(
              json['my_list_status'] as Map<String, dynamic>)
      ..authors = (json['authors'] as List<dynamic>?)
          ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
          .toList()
      ..numEpisodes = json['num_episodes'] as int?
      ..numChapters = json['num_chapters'] as int?
      ..numVolumes = json['num_volumes'] as int?;

Map<String, dynamic> _$MediaNodeToJson(MediaNode instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'synopsis': instance.synopsis,
      'mean': instance.mean,
      'media_type': instance.mediaType,
      'status': instance.status,
      'nsfw': instance.nsfw,
      'main_picture': instance.mediaPicture,
      'genres': instance.genres,
      'pictures': instance.pictures,
      'alternative_titles': instance.alternativeTitles,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'rank': instance.rank,
      'popularity': instance.popularity,
      'num_list_users': instance.numListUsers,
      'num_scoring_users': instance.numScoringUsers,
      'start_season': instance.startSeason,
      'source': instance.source,
      'average_episode_duration': instance.averageEpsDuration,
      'rating': instance.rating,
      'studios': instance.studios,
      'my_list_status': instance.userMediaStatus,
      'authors': instance.authors,
      'num_episodes': instance.numEpisodes,
      'num_chapters': instance.numChapters,
      'num_volumes': instance.numVolumes,
    };
