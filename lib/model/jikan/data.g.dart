// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data()
  ..data = (json['data'] as List<dynamic>?)
      ?.map((e) => JikanMedia.fromJson(e as Map<String, dynamic>))
      .toList()
  ..pagination = json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'data': instance.data,
      'pagination': instance.pagination,
    };
