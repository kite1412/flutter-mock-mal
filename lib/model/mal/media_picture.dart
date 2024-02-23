import 'package:anime_gallery/model/jikan/image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_picture.g.dart';

// media's picture
@JsonSerializable()
class MediaPicture {
  String medium;
  String large;

  MediaPicture(this.medium, this.large);

  static MediaPicture fromJikanImage(Image image) {
    return MediaPicture(image.jpg!.imageUrl!, image.jpg?.largeImageUrl ?? image.jpg!.imageUrl!);
  }

  factory MediaPicture.empty() {
    return MediaPicture("", "");
  }

  static MediaPicture assertMediaPicture(MediaPicture? mediaPicture) {
    if (mediaPicture != null) {
      return mediaPicture;
    } else {
      return MediaPicture.empty();
    }
  }

  // Required factor constructor for deserialization
  factory MediaPicture.fromJson(Map<String, dynamic> json) => _$MediaPictureFromJson(json);

  // Required method for serialization
  Map<String, dynamic> toJson() => _$MediaPictureToJson(this);
}