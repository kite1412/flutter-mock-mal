// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceData _$ResourceDataFromJson(Map<String, dynamic> json) => ResourceData()
  ..data = (json['data'] as List<dynamic>?)
      ?.map((e) => Resource.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ResourceDataToJson(ResourceData instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
