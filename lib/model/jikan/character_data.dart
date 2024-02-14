import 'package:anime_gallery/model/jikan/character.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_data.g.dart';

@JsonSerializable()
class CharacterData {
  List<Character>? data;

  CharacterData();

  // Required factor constructor for deserialization
  factory CharacterData.fromJson(Map<String, dynamic> json) => _$CharacterDataFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$CharacterDataToJson(this);
}