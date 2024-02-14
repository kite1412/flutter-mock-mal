// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_with_node_ranked.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataWithRank _$DataWithRankFromJson(Map<String, dynamic> json) => DataWithRank(
      (json['data'] as List<dynamic>)
          .map((e) => MediaNodeRanked.fromJson(e as Map<String, dynamic>))
          .toList(),
      Paging.fromJson(json['paging'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataWithRankToJson(DataWithRank instance) =>
    <String, dynamic>{
      'data': instance.data,
      'paging': instance.paging,
    };
