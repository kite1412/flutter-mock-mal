import 'package:anime_gallery/model/mal/node_with_rank.dart';
import 'package:anime_gallery/model/mal/paging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_with_node_ranked.g.dart';

@JsonSerializable()
class DataWithRank {
  List<MediaNodeRanked> data;
  Paging paging;

  DataWithRank(this.data, this.paging);

  factory DataWithRank.empty() {
    return DataWithRank([], Paging.empty());
  }

  // Required factor constructor for deserialization
  factory DataWithRank.fromJson(Map<String, dynamic> json) => _$DataWithRankFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$DataWithRankToJson(this);
}