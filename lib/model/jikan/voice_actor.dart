import 'package:anime_gallery/model/jikan/person.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voice_actor.g.dart';

@JsonSerializable()
class VoiceActor {
  Person? person;
  String? language;

  VoiceActor();

  // Required factor constructor for deserialization
  factory VoiceActor.fromJson(Map<String, dynamic> json) => _$VoiceActorFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$VoiceActorToJson(this);
}