import 'package:json_annotation/json_annotation.dart';

part 'alternative_titles.g.dart';

@JsonSerializable()
class AlternativeTitles {
  List<String>? synonyms;
  String? en;
  String? ja;

  AlternativeTitles(this.synonyms, this.en, this.ja);


  // Required factor constructor for deserialization
  factory AlternativeTitles.fromJson(Map<String, dynamic> json) => _$AlternativeTitlesFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$AlternativeTitlesToJson(this);
}