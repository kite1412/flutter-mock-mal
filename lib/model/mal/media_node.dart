import 'package:anime_gallery/model/mal/start_season.dart';
import 'package:anime_gallery/model/mal/studio.dart';
import 'package:anime_gallery/model/mal/user_media_status.dart';
import 'package:json_annotation/json_annotation.dart';

import '../jikan/media.dart';
import 'alternative_titles.dart';
import 'author.dart';
import 'genre.dart';
import 'media_picture.dart';

part 'media_node.g.dart';

// anime and manga data representation
@JsonSerializable()
class MediaNode {
  int id;
  String title;
  String? synopsis;
  double? mean;
  @JsonKey(name: "media_type")
  String? mediaType;
  String? status;
  String? nsfw;
  @JsonKey(name: "main_picture")
  MediaPicture mediaPicture;
  List<Genre>? genres;
  List<MediaPicture>? pictures;
  @JsonKey(name: "alternative_titles")
  AlternativeTitles? alternativeTitles;
  String? startDate;
  String? endDate;
  int? rank;
  int? popularity;
  @JsonKey(name: "num_list_users")
  int? numListUsers;
  @JsonKey(name: "num_scoring_users")
  int? numScoringUsers;
  @JsonKey(name: "start_season")
  StartSeason? startSeason;
  String? source;
  @JsonKey(name: "average_episode_duration")
  int? averageEpsDuration;
  String? rating;
  List<Studio>? studios;
  @JsonKey(name: "my_list_status")
  UserMediaStatus? userMediaStatus;
  List<Author>? authors;
  @JsonKey(name: "num_episodes")
  int? numEpisodes;
  @JsonKey(name: "num_chapters")
  int? numChapters;
  @JsonKey(name: "num_volumes")
  int? numVolumes;

  MediaNode(this.id, this.title, this.mediaPicture);

  static MediaNode from(MediaNode source) {
    return MediaNode(source.id, source.title, source.mediaPicture)
      ..mean = source.mean
      ..numScoringUsers = source.numScoringUsers
      ..popularity = source.popularity
      ..rank = source.rank
      ..mediaType = source.mediaType
      ..status = source.status
      ..synopsis = source.synopsis
      ..pictures = source.pictures
      ..genres = source.genres
      ..alternativeTitles = source.alternativeTitles
      ..startSeason = source.startSeason
      ..rating = source.rating
      ..studios = source.studios
      ..userMediaStatus = source.userMediaStatus
      ..numEpisodes = source.numEpisodes
      ..numChapters = source.numChapters
      ..numVolumes = source.numVolumes
      ..authors = source.authors;
  }

  static MediaNode fromJikanMedia(JikanMedia media) {
    return MediaNode(
      media.malId!,
      media.titles![0].title!,
      MediaPicture.fromJikanImage(media.images!)
    )
      ..rank = media.rank
      ..mean = media.score
      ..synopsis = media.synopsis
      ..status = media.status
      ..mediaType = media.type;
  }

  static List<MediaNode> fromJikanMediaList(List<JikanMedia> list) {
    return list.map((e) =>
      MediaNode.fromJikanMedia(e)
    ).toList();
  }

  factory MediaNode.empty() {
    return MediaNode(-1, "", MediaPicture.empty());
  }

  static MediaNode assertMediaNode(MediaNode? mediaNode) {
    if (mediaNode != null) {
      return mediaNode;
    } else {
      return MediaNode.empty();
    }
  }

  // Required factor constructor for deserialization
  factory MediaNode.fromJson(Map<String, dynamic> json) => _$MediaNodeFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$MediaNodeToJson(this);

}
