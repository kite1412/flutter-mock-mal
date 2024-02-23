import 'package:anime_gallery/model/jikan/pagination.dart';
import 'package:json_annotation/json_annotation.dart';

import 'media.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  List<JikanMedia>? data;
  Pagination? pagination;

  Data();

  // Required factor constructor for deserialization
  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$DataToJson(this);
}