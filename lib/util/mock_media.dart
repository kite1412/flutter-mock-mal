import 'package:anime_gallery/model/jikan/image.dart';
import 'package:anime_gallery/model/jikan/media.dart';
import 'package:anime_gallery/model/jikan/title.dart';

import '../model/mal/media_node.dart';
import '../model/mal/media_picture.dart';

class MockMedia {
  static List<MediaNode> mockAnime = [
    MediaNode(0, "One Piece", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(1, "Naruto", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(2, "Black Clover", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(3, "Highschool DXD", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(4, "Berserk", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(5, "Code Geass", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(6, "Re:Zero", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(7, "Highschool of the Dead", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(8, "Cowboy Bebop", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(9, "Date a Live", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(0, "One Piece", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(1, "Naruto", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(2, "Black Clover", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(3, "Highschool DXD", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(4, "Berserk", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(5, "Code Geass", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(6, "Re:Zero", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(7, "Highschool of the Dead", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(8, "Cowboy Bebop", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
    MediaNode(9, "Date a Live", MediaPicture("https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg", "")),
  ];

  static ImageFormat jpg = ImageFormat()..imageUrl = "https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty-300x240.jpg";
  static Image image = Image()..jpg = jpg;

  static List<JikanMedia> mockJikanMedia = [
    JikanMedia()..titles = [Title()..title = "asdasdasdasdasdasdasdasdasdasdsad"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Berserk"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Naruto"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Kimi no Nawa"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Oresuki"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Zero no Tsukaima"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Black Clover"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "Vagabond"]
      ..images = image,
    JikanMedia()..titles = [Title()..title = "November Rain"]
      ..images = image,
  ];
}