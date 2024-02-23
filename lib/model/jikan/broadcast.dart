import 'package:json_annotation/json_annotation.dart';

part 'broadcast.g.dart';

@JsonSerializable()
class Broadcast {
  String? day;
  String? time;
  String? timezone;
  String? string;

  Broadcast();

  // Required factor constructor for deserialization
  factory Broadcast.fromJson(Map<String, dynamic> json) => _$BroadcastFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$BroadcastToJson(this);
}