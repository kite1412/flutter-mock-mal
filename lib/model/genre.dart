import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre {
  int id;
  String name;

  Genre(this.id, this.name);

  // Required factor constructor for deserialization
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}