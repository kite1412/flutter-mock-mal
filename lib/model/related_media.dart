import 'package:json_annotation/json_annotation.dart';

import 'media_node.dart';

part 'related_media.g.dart';

@JsonSerializable()
class RelatedMedia {
  @JsonKey(name: "node")
  List<Map<String, MediaNode>> relatedMedia;
  @JsonKey(name: "relation_type")
  String relationType;
  @JsonKey(name: "relation_type_formatted")
  String relationTypeFormatted;

  RelatedMedia(this.relatedMedia, this.relationType, this.relationTypeFormatted);


  // Required factor constructor for deserialization
  factory RelatedMedia.fromJson(Map<String, dynamic> json) => _$RelatedMediaFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$RelatedMediaToJson(this);
}