import 'package:json_annotation/json_annotation.dart';

part 'user_information.g.dart';

@JsonSerializable()
class UserInformation {
  int id;
  String name;
  String picture;
  String? gender;
  String? birthday;
  String? location;
  @JsonKey(name: "joined_at")
  String joinedAt;
  @JsonKey(name: "time_zone")
  String? timeZone;
  // TODO anime_statistics object

  UserInformation(this.id, this.name, this.picture,
      this.gender, this.birthday, this.location,
      this.joinedAt, this.timeZone);

  factory UserInformation.empty() {
    return UserInformation(-1, "", "", "", "", "", "", "");
  }

  // Required factor constructor for deserialization
  factory UserInformation.fromJson(Map<String, dynamic> json) => _$UserInformationFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$UserInformationToJson(this);
}