
import 'package:flutter/cupertino.dart';
import 'package:pg_slema/utils/token/token_service.dart';

enum ChatMainScreenType {
  SIGN_IN_SCREEN,
  SIGN_UP_SCREEN,
  MAIN_LOADING_SCREEN,
  CHATS_SCREEN,
  USER_SCREEN,

}

class ChatMainScreenController extends ChangeNotifier {
  int _currentIndex = 4;
  bool _hasBottomBar = false;

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  bool get hasBottomBar => _hasBottomBar;
  set hasBottomBar(bool value) {
    _hasBottomBar = value;
    notifyListeners();
  }

  final PageController pageController = PageController();

  void navigateTo(ChatMainScreenType screenType) {
    currentIndex = _indexFromScreenType(screenType);
    hasBottomBar = _hasBottomBarFromScreenType(screenType);
  }

  int _indexFromScreenType(ChatMainScreenType screenType) {
    switch(screenType) {
      case ChatMainScreenType.SIGN_IN_SCREEN:
        return 0;
      case ChatMainScreenType.SIGN_UP_SCREEN:
        return 1;
      case ChatMainScreenType.CHATS_SCREEN:
        return 2;
      case ChatMainScreenType.USER_SCREEN:
        return 3;
      case ChatMainScreenType.MAIN_LOADING_SCREEN:
        return 4;
      default:
        return 0;
    }
  }

  bool _hasBottomBarFromScreenType(ChatMainScreenType screenType) {
    switch(screenType) {
      case ChatMainScreenType.SIGN_IN_SCREEN:
        return false;
      case ChatMainScreenType.SIGN_UP_SCREEN:
        return false;
      case ChatMainScreenType.CHATS_SCREEN:
        return true;
      case ChatMainScreenType.USER_SCREEN:
        return true;
      case ChatMainScreenType.MAIN_LOADING_SCREEN:
        return false;
      default:
        return false;
    }
  }





  //void indexFromScreen
}