import 'package:json_annotation/json_annotation.dart';

part 'user_media_status.g.dart';

@JsonSerializable()
class UserMediaStatus {
  String? status;
  int score;
  @JsonKey(name: "num_episodes_watched")
  int? numEpisodesWatched;
  @JsonKey(name: "is_rewatching")
  bool? isRewatching;
  @JsonKey(name: "start_date")
  String? startDate;
  @JsonKey(name: "finish_date")
  String? finishDate;
  int? priority;
  @JsonKey(name: "num_times_rewatched")
  int? numTimesRewatched;
  @JsonKey(name: "rewatch_value")
  int? rewatchValue;
  List<String>? tags;
  String? comments;
  @JsonKey(name: "updated_at")
  String updatedAt;

  //for manga
  @JsonKey(name: "is_rereading")
  bool? isRereading;
  @JsonKey(name: "num_volumes_read")
  int? numVolumesRead;
  @JsonKey(name: "num_chapters_read")
  int? numChaptersRead;

  UserMediaStatus(
    this.score,
    this.updatedAt,
  );

  // Required factor constructor for deserialization
  factory UserMediaStatus.fromJson(Map<String, dynamic> json) => _$UserMediaStatusFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$UserMediaStatusToJson(this);
}