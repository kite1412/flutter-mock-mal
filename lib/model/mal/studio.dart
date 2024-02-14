import 'package:json_annotation/json_annotation.dart';

part 'studio.g.dart';

@JsonSerializable()
class Studio {
  int id;
  String name;

  Studio(this.id, this.name);


  // Required factor constructor for deserialization
  factory Studio.fromJson(Map<String, dynamic> json) => _$StudioFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$StudioToJson(this);
}