import 'package:anime_gallery/model/media_node.dart';
import 'package:json_annotation/json_annotation.dart';

part 'node_with_rank.g.dart';

@JsonSerializable()
class MediaNodeRanked {
  MediaNode node;
  Ranking ranking;

  MediaNodeRanked(this.node, this.ranking);

  static MediaNode toMediaNode(MediaNodeRanked nodeWithRanking) {
    return MediaNode.from(nodeWithRanking.node);
  }

  // Required factor constructor for deserialization
  factory MediaNodeRanked.fromJson(Map<String, dynamic> json) => _$MediaNodeRankedFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$MediaNodeRankedToJson(this);
}

@JsonSerializable()
class Ranking {
  int rank;

  Ranking(this.rank);

  // Required factor constructor for deserialization
  factory Ranking.fromJson(Map<String, dynamic> json) => _$RankingFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$RankingToJson(this);
}