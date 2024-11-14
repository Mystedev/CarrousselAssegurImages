import 'package:flutter/foundation.dart';

class UrlModel with ChangeNotifier {
  String _linkUrl = '';

  String get linkUrl => _linkUrl;

  void setLinkUrl(String url) {
    _linkUrl = url;
    notifyListeners();
  }
}
