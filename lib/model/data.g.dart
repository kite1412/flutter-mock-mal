// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      (json['data'] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, MediaNode.fromJson(e as Map<String, dynamic>)),
              ))
          .toList(),
      Paging.fromJson(json['paging'] as Map<String, dynamic>),
    )..season = json['season'] == null
        ? null
        : Season.fromJson(json['season'] as Map<String, dynamic>);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'data': instance.mediaNodes,
      'paging': instance.paging,
      'season': instance.season,
    };
