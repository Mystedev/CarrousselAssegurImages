import 'package:flutter/material.dart';

class FetchController extends ChangeNotifier {
  bool isFetching = true;

  void stopFetching() {
    isFetching = false;
    notifyListeners();
  }

  void startFetching() {
    isFetching = true;
    notifyListeners();
  }
}
