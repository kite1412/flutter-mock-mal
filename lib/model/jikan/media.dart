import 'package:anime_gallery/model/jikan/broadcast.dart';
import 'package:anime_gallery/model/jikan/date_range.dart';
import 'package:anime_gallery/model/jikan/image.dart';
import 'package:anime_gallery/model/jikan/resource.dart';
import 'package:anime_gallery/model/jikan/title.dart';
import 'package:anime_gallery/model/jikan/trailer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media.g.dart';

@JsonSerializable()
class JikanMedia {
  @JsonKey(name: "mal_id")
  int? malId;
  String? url;
  Image? images;
  Trailer? trailer;
  bool? approved;
  List<Title>? titles;
  String? title;
  @JsonKey(name: "title_english")
  String? titleEnglish;
  @JsonKey(name: "title_japanese")
  String? titleJapanese;
  @JsonKey(name: "title_synonyms")
  List<String>? titleSynonyms;
  String? type;
  String? source;
  int? episodes;
  String? status;
  bool? airing;
  DateRange? aired;
  String? duration;
  String? rating;
  double? score;
  @JsonKey(name: "scored_by")
  int? scoredBy;
  int? rank;
  int? popularity;
  int? members;
  int? favorites;
  String? synopsis;
  String? background;
  String? season;
  int? year;
  Broadcast? broadcast;
  List<Resource>? producers;
  List<Resource>? licensors;
  List<Resource>? studios;
  List<Resource>? genres;
  @JsonKey(name: "explicit_genres")
  List<Resource>? explicitGenres;
  List<Resource>? themes;
  List<Resource>? demographics;

  JikanMedia();

  // Required factor constructor for deserialization
  factory JikanMedia.fromJson(Map<String, dynamic> json) => _$JikanMediaFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$JikanMediaToJson(this);
}