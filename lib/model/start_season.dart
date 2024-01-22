import 'package:json_annotation/json_annotation.dart';

part 'start_season.g.dart';

@JsonSerializable()
class StartSeason {
  int year;
  String season;

  StartSeason(this.year, this.season);


  // Required factor constructor for deserialization
  factory StartSeason.fromJson(Map<String, dynamic> json) => _$StartSeasonFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$StartSeasonToJson(this);
}