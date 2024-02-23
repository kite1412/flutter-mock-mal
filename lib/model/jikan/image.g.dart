// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image()
  ..jpg = json['jpg'] == null
      ? null
      : ImageFormat.fromJson(json['jpg'] as Map<String, dynamic>)
  ..webp = json['webp'] == null
      ? null
      : ImageFormat.fromJson(json['webp'] as Map<String, dynamic>);

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'jpg': instance.jpg,
      'webp': instance.webp,
    };

ImageFormat _$ImageFormatFromJson(Map<String, dynamic> json) => ImageFormat()
  ..imageUrl = json['image_url'] as String?
  ..smallImageUrl = json['small_image_url'] as String?
  ..mediumImageUrl = json['medium_image_url'] as String?
  ..largeImageUrl = json['large_image_url'] as String?
  ..maximumImageUrl = json['maximum_image_url'] as String?;

Map<String, dynamic> _$ImageFormatToJson(ImageFormat instance) =>
    <String, dynamic>{
      'image_url': instance.imageUrl,
      'small_image_url': instance.smallImageUrl,
      'medium_image_url': instance.mediumImageUrl,
      'large_image_url': instance.largeImageUrl,
      'maximum_image_url': instance.maximumImageUrl,
    };
