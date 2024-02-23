import 'package:json_annotation/json_annotation.dart';

part 'resource.g.dart';

@JsonSerializable()
class Resource {
  @JsonKey(name: "mal_id")
  int? malId;
  String? type;
  String? name;
  String? url;

  Resource();

  // Required factor constructor for deserialization
  factory Resource.fromJson(Map<String, dynamic> json) => _$ResourceFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$ResourceToJson(this);
}