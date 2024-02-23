import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class Image {
  ImageFormat? jpg;
  ImageFormat? webp;

  Image();

  // Required factor constructor for deserialization
  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable()
class ImageFormat {
  @JsonKey(name: "image_url")
  String? imageUrl;
  @JsonKey(name: "small_image_url")
  String? smallImageUrl;
  @JsonKey(name: "medium_image_url")
  String? mediumImageUrl;
  @JsonKey(name: "large_image_url")
  String? largeImageUrl;
  @JsonKey(name: "maximum_image_url")
  String? maximumImageUrl;

  ImageFormat();

  // Required factor constructor for deserialization
  factory ImageFormat.fromJson(Map<String, dynamic> json) => _$ImageFormatFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$ImageFormatToJson(this);
}