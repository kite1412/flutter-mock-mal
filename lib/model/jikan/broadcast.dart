import 'package:json_annotation/json_annotation.dart';

import '../../util/time_util.dart';

part 'broadcast.g.dart';

@JsonSerializable()
class Broadcast {
  String? day;
  String? time;
  String? timezone;
  String? string;

  Broadcast();

  Time getTime() {
    final mTime = time!.split(":");
    return Time(hour: int.parse(mTime[0]), minute: int.parse(mTime[1]));
  }

  // Required factor constructor for deserialization
  factory Broadcast.fromJson(Map<String, dynamic> json) => _$BroadcastFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$BroadcastToJson(this);
}