// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character()
  ..character = json['character'] == null
      ? null
      : CharacterInfo.fromJson(json['character'] as Map<String, dynamic>)
  ..role = json['role'] as String?
  ..voiceActors = (json['voice_actors'] as List<dynamic>?)
      ?.map((e) => VoiceActor.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'character': instance.character,
      'role': instance.role,
      'voice_actors': instance.voiceActors,
    };
