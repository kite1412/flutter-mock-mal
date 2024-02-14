// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInformation _$UserInformationFromJson(Map<String, dynamic> json) =>
    UserInformation(
      json['id'] as int,
      json['name'] as String,
      json['picture'] as String,
      json['gender'] as String?,
      json['birthday'] as String?,
      json['location'] as String?,
      json['joined_at'] as String,
      json['time_zone'] as String?,
    );

Map<String, dynamic> _$UserInformationToJson(UserInformation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'location': instance.location,
      'joined_at': instance.joinedAt,
      'time_zone': instance.timeZone,
    };
