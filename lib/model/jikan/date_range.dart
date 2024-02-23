import 'package:json_annotation/json_annotation.dart';

part 'date_range.g.dart';

@JsonSerializable()
class DateRange {
  String? from;
  String? to;
  DateProp? prop;

  DateRange();

  // Required factor constructor for deserialization
  factory DateRange.fromJson(Map<String, dynamic> json) => _$DateRangeFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}

@JsonSerializable()
class DateProp {
  Prop? from;
  Prop? to;
  String? string;

  DateProp();

  // Required factor constructor for deserialization
  factory DateProp.fromJson(Map<String, dynamic> json) => _$DatePropFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$DatePropToJson(this);
}

@JsonSerializable()
class Prop {
  int? day;
  int? month;
  int? year;

  Prop();

  // Required factor constructor for deserialization
  factory Prop.fromJson(Map<String, dynamic> json) => _$PropFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$PropToJson(this);
}