import 'package:json_annotation/json_annotation.dart';

part 'access_token.g.dart';

@JsonSerializable()
class AccessToken {
  String? tokenType;
  @JsonKey(name: "expires_in")
  int? expiresIn;
  @JsonKey(name: "access_token")
  String? token;
  @JsonKey(name: "refresh_token")
  String? refreshToken;

  AccessToken();

  // Required factor constructor for deserialization
  factory AccessToken.fromJson(Map<String, dynamic> json) => _$AccessTokenFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$AccessTokenToJson(this);
}