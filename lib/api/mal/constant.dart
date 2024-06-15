class MalConstant {
  MalConstant._();

  static final Uri uri = Uri.parse("https://api.myanimelist.net/v2");
  static const uriString = "https://api.myanimelist.net/v2";
  static const userInformationUrl = "$uriString/users/@me";
  static const tokenEndpoint = "https://myanimelist.net/v1/oauth2/token";
  static const redirectUriAndroid = "com.nrr://handler";
  static const scopes = ["write:users"];
}