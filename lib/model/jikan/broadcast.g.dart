// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Broadcast _$BroadcastFromJson(Map<String, dynamic> json) => Broadcast()
  ..day = json['day'] as String?
  ..time = json['time'] as String?
  ..timezone = json['timezone'] as String?
  ..string = json['string'] as String?;

Map<String, dynamic> _$BroadcastToJson(Broadcast instance) => <String, dynamic>{
      'day': instance.day,
      'time': instance.time,
      'timezone': instance.timezone,
      'string': instance.string,
    };
