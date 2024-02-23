// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination()
  ..lastVisiblePage = json['last_visible_page'] as int?
  ..hasNextPage = json['has_next_page'] as bool?
  ..currentPage = json['current_page'] as int?
  ..items = json['items'] == null
      ? null
      : RequestInfo.fromJson(json['items'] as Map<String, dynamic>);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'last_visible_page': instance.lastVisiblePage,
      'has_next_page': instance.hasNextPage,
      'current_page': instance.currentPage,
      'items': instance.items,
    };

RequestInfo _$RequestInfoFromJson(Map<String, dynamic> json) => RequestInfo()
  ..count = json['count'] as int?
  ..total = json['total'] as int?
  ..perPage = json['per_page'] as int?;

Map<String, dynamic> _$RequestInfoToJson(RequestInfo instance) =>
    <String, dynamic>{
      'count': instance.count,
      'total': instance.total,
      'per_page': instance.perPage,
    };
