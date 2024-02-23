import 'package:json_annotation/json_annotation.dart';

part 'title.g.dart';

@JsonSerializable()
class Title {
  String? type;
  String? title;

  Title();

  // Required factor constructor for deserialization
  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$TitleToJson(this);
}