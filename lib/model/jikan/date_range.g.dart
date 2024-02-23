// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange()
  ..from = json['from'] as String?
  ..to = json['to'] as String?
  ..prop = json['prop'] == null
      ? null
      : DateProp.fromJson(json['prop'] as Map<String, dynamic>);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'prop': instance.prop,
    };

DateProp _$DatePropFromJson(Map<String, dynamic> json) => DateProp()
  ..from = json['from'] == null
      ? null
      : Prop.fromJson(json['from'] as Map<String, dynamic>)
  ..to = json['to'] == null
      ? null
      : Prop.fromJson(json['to'] as Map<String, dynamic>)
  ..string = json['string'] as String?;

Map<String, dynamic> _$DatePropToJson(DateProp instance) => <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'string': instance.string,
    };

Prop _$PropFromJson(Map<String, dynamic> json) => Prop()
  ..day = json['day'] as int?
  ..month = json['month'] as int?
  ..year = json['year'] as int?;

Map<String, dynamic> _$PropToJson(Prop instance) => <String, dynamic>{
      'day': instance.day,
      'month': instance.month,
      'year': instance.year,
    };
