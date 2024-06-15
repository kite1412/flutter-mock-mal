// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessToken _$AccessTokenFromJson(Map<String, dynamic> json) => AccessToken()
  ..tokenType = json['tokenType'] as String?
  ..expiresIn = json['expires_in'] as int?
  ..token = json['access_token'] as String?
  ..refreshToken = json['refresh_token'] as String?;

Map<String, dynamic> _$AccessTokenToJson(AccessToken instance) =>
    <String, dynamic>{
      'tokenType': instance.tokenType,
      'expires_in': instance.expiresIn,
      'access_token': instance.token,
      'refresh_token': instance.refreshToken,
    };
