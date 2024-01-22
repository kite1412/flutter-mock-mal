// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_with_rank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaNodeRanked _$MediaNodeRankedFromJson(Map<String, dynamic> json) =>
    MediaNodeRanked(
      MediaNode.fromJson(json['node'] as Map<String, dynamic>),
      Ranking.fromJson(json['ranking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaNodeRankedToJson(MediaNodeRanked instance) =>
    <String, dynamic>{
      'node': instance.node,
      'ranking': instance.ranking,
    };

Ranking _$RankingFromJson(Map<String, dynamic> json) => Ranking(
      json['rank'] as int,
    );

Map<String, dynamic> _$RankingToJson(Ranking instance) => <String, dynamic>{
      'rank': instance.rank,
    };
