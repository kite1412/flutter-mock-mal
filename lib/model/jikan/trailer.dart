import 'package:json_annotation/json_annotation.dart';

import 'image.dart';

part 'trailer.g.dart';

@JsonSerializable()
class Trailer {
  @JsonKey(name: "youtube_id")
  String? youtubeId;
  String? url;
  @JsonKey(name: "embed_url")
  String? embedUrl;
  Image? images;

  Trailer();

  // Required factor constructor for deserialization
  factory Trailer.fromJson(Map<String, dynamic> json) => _$TrailerFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$TrailerToJson(this);
}