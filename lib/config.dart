import 'dart:html' as html;

class Config {
  static String getServerIp() {
    String uri = "";
    // uri = "http://localhost";
    // uri = "http://10.17.107.113";
    uri = html.window.location.origin;
    return uri;
  }
}
