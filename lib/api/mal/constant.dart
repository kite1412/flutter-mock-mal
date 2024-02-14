class MalConstant {
  MalConstant._();

  static final Uri uri = Uri.parse("https://api.myanimelist.net/v2");
  static const uriString = "https://api.myanimelist.net/v2";
  static const userInformationUrl = "$uriString/users/@me";

  static const clientId = "b733180d69f62b4b2d9e7820ce9d9968";
  static const clientSecret = "";
  static const redirectUriAndroid = "com.nrr://handler";
  static const scopes = ["write:users"];
}