import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  int id;
  @JsonKey(name: "first_name")
  String firstName;
  @JsonKey(name: "last_name")
  String lastName;

  Person(this.id, this.firstName, this.lastName);

  // Required factor constructor for deserialization
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}