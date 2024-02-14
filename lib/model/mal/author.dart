import 'package:anime_gallery/model/mal/person.dart';
import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  Person node;
  String role;

  Author(this.node, this.role);

  // Required factor constructor for deserialization
  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}