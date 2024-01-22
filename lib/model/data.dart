import 'package:anime_gallery/model/paging.dart';
import 'package:anime_gallery/model/season.dart';
import 'package:json_annotation/json_annotation.dart';

import 'media_node.dart';

part 'data.g.dart';

// data represented as the response of api request
@JsonSerializable()
class Data {
  @JsonKey(name: "data")
  List<Map<String, MediaNode>> mediaNodes;
  @JsonKey(name: "paging")
  Paging paging;
  Season? season;


  Data(this.mediaNodes, this.paging);

  factory Data.empty() {
   return Data([], Paging.empty());
 }

  // Required factor constructor for deserialization
  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$DataToJson(this);
}