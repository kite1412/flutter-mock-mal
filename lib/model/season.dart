import 'package:json_annotation/json_annotation.dart';

part 'season.g.dart';

@JsonSerializable()
class Season {
  int year;
  String season;

  Season(this.year, this.season);

  // Required factor constructor for deserialization
  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$SeasonToJson(this);
}