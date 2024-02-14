import 'package:anime_gallery/model/jikan/image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_info.g.dart';

@JsonSerializable()
class CharacterInfo {
  @JsonKey(name: "mal_id")
  int? malId;
  String? url;
  Image? images;
  String? name;

  CharacterInfo();

  // Required factor constructor for deserialization
  factory CharacterInfo.fromJson(Map<String, dynamic> json) => _$CharacterInfoFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$CharacterInfoToJson(this);
}