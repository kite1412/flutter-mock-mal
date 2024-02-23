import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable()
class Pagination {
  @JsonKey(name: "last_visible_page")
  int? lastVisiblePage;
  @JsonKey(name: "has_next_page")
  bool? hasNextPage;
  @JsonKey(name: "current_page")
  int? currentPage;
  RequestInfo? items;

  Pagination();

  // Required factor constructor for deserialization
  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable()
class RequestInfo {
  int? count;
  int? total;
  @JsonKey(name: "per_page")
  int? perPage;

  RequestInfo();

  // Required factor constructor for deserialization
  factory RequestInfo.fromJson(Map<String, dynamic> json) => _$RequestInfoFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$RequestInfoToJson(this);
}