import 'package:anime_gallery/model/jikan/resource.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resource_data.g.dart';

@JsonSerializable()
class ResourceData {
  List<Resource>? data;

  ResourceData();

  // Required factor constructor for deserialization
  factory ResourceData.fromJson(Map<String, dynamic> json) => _$ResourceDataFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$ResourceDataToJson(this);
}