import 'package:anime_gallery/model/start_season.dart';
import 'package:anime_gallery/model/studio.dart';
import 'package:anime_gallery/model/user_media_status.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alternative_titles.dart';
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
      ..pictures = source.pictures;
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
