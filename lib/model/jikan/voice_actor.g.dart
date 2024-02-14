// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_actor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoiceActor _$VoiceActorFromJson(Map<String, dynamic> json) => VoiceActor()
  ..person = json['person'] == null
      ? null
      : Person.fromJson(json['person'] as Map<String, dynamic>)
  ..language = json['language'] as String?;

Map<String, dynamic> _$VoiceActorToJson(VoiceActor instance) =>
    <String, dynamic>{
      'person': instance.person,
      'language': instance.language,
    };
