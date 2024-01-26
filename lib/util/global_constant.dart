import '../model/media_node.dart';

class GlobalConstant {
  //Not to be instantiated
  GlobalConstant._();

  static const List<String> tabs = [
    "Anime",
    "Manga",
  ];
  static const spAccessToken = "accessToken";

  static const mandatoryFields = [
    "synopsis",
    "mean",
    "media_type",
    "status",
    "genres",
    "num_scoring_users",
    "rank",
    "popularity",
    "my_list_status",
    "alternative_titles",
    "start_season",
    "rating",
    "studios",
    "start_date",
    "end_date",
  ];

  static const mangaMandatoryFields = [
    "synopsis",
    "mean",
    "media_type",
    "status",
    "genres",
    "num_scoring_users",
    "rank",
    "popularity",
    "my_list_status",
    "alternative_titles",
    "authors{first_name, last_name}"
  ];

  static const spSearchHistory = "searches-history";
}