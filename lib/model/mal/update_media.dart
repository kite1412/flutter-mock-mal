import 'package:json_annotation/json_annotation.dart';

part 'update_media.g.dart';

@JsonSerializable()
class UpdateMedia {
  String? status;
  int? score;
  bool? isRewatching;
  @JsonKey(name: "num_episodes_watched")
  int? numEpisodesWatched;
  int? priority;
  @JsonKey(name: "num_times_rewatched")
  int? numTimesRewatched;
  @JsonKey(name: "rewatch_value")
  int? rewatchValue;
  List<String>? tags;
  String? comments;
  @JsonKey(name: "start_date")
  String? startDate;
  @JsonKey(name: "finish_date")
  String? finishDate;
  @JsonKey(name: "updated_at")
  String? updatedAt;
  @JsonKey(name: "num_chapters_read")
  int? numChaptersRead;

  UpdateMedia();

  static Map<String, dynamic> anime(
    String? status,
    int? score,
    int? progress
  ) => {
    if (status != null) "status" : status,
    if (score != null) "score" : score,
    if (progress != null) "num_watched_episodes" : progress,
  };

  static Map<String, dynamic> manga(
    String? status,
    int? score,
    int? progress
  ) => {
    if (status != null) "status" : status,
    if (score != null) "score" : score,
    if (progress != null) "num_chapters_read" : progress,
  };

  // Required factor constructor for deserialization
  factory UpdateMedia.fromJson(Map<String, dynamic> json) => _$UpdateMediaFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$UpdateMediaToJson(this);
}