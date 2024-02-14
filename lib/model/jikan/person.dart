import 'package:anime_gallery/model/jikan/image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  @JsonKey(name: "mal_id")
  int? malId;
  String? url;
  ImageFormat? images;
  String? name;

  Person();

  // Required factor constructor for deserialization
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}