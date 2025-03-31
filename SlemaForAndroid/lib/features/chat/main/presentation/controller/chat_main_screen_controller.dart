
import 'package:flutter/cupertino.dart';

enum ChatMainScreenType {
  SIGN_IN_SCREEN,
  SIGN_UP_SCREEN
}

class ChatMainScreenController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  final PageController pageController = PageController();

  void navigateTo(ChatMainScreenType screenType) {
    currentIndex = _indexFromScreenType(screenType);
  }

  int _indexFromScreenType(ChatMainScreenType screenType) {
    switch(screenType) {
      case ChatMainScreenType.SIGN_IN_SCREEN:
        return 0;
      case ChatMainScreenType.SIGN_UP_SCREEN:
        return 1;
    }
  }



  //void indexFromScreen
}