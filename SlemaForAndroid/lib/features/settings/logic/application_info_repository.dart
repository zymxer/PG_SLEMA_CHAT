abstract class ApplicationInfoRepository {
  String getServerAddress();

  void setServerAddress(String value);

  //Todo remove when WebSocket implemented via gateway service
  String getChatServiceAddress();

  void setChatServiceAddress(String value);

  String getVersion();

  String getBuildNumber();

  bool isDeveloperMode();

  void setDeveloperMode(bool value);
}
