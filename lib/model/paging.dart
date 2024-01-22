import 'package:json_annotation/json_annotation.dart';

part 'paging.g.dart';

// next page of current request
@JsonSerializable()
class Paging {
  String? previous;
  @JsonKey(name: "next")
  String? next;

  Paging(this.previous, this.next);

  factory Paging.empty() {
    return Paging("", "");
  }

  // Required factor constructor for deserialization
  factory Paging.fromJson(Map<String, dynamic> json) => _$PagingFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$PagingToJson(this);
}