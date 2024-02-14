import 'package:anime_gallery/model/jikan/character_info.dart';
import 'package:anime_gallery/model/jikan/voice_actor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  CharacterInfo? character;
  String? role;
  @JsonKey(name: "voice_actors")
  List<VoiceActor>? voiceActors;

  Character();

  // Required factor constructor for deserialization
  factory Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}