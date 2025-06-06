
import 'package:flutter/cupertino.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:provider/provider.dart';

enum ChatMainScreenType {
  SIGN_IN_SCREEN,
  SIGN_UP_SCREEN,
  MAIN_LOADING_SCREEN,
  CHATS_SCREEN,
  USER_SCREEN,

}

// class _ChatScreenInfo {
//   final int index;
//   final bool hasBottomBar;
// }

class ChatMainScreenController extends ChangeNotifier {
  int _currentIndex = 4;
  ChatMainScreenType _currentScreen = ChatMainScreenType.MAIN_LOADING_SCREEN;
  bool _hasBottomBar = false;

  //final Map<ChatMainScreenType, _ChatScreenInfo> _screensInfo = Map();

  ChatMainScreenController() {  // TODO
    //_screensInfo[ChatMainScreenType.SIGN_IN_SCREEN] = _ChatScreenInfo()
  }

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    if(_currentIndex == index) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  ChatMainScreenType get currentScreen => _currentScreen;
  set currentScreen(ChatMainScreenType type) {
    if(_currentScreen == type) {
      return;
    }
    _currentScreen = type;
    notifyListeners();
  }

  bool get hasBottomBar => _hasBottomBar;
  set hasBottomBar(bool value) {
    _hasBottomBar = value;
    notifyListeners();
  }

  final PageController pageController = PageController();

  void navigateTo(ChatMainScreenType screenType) {
    final index = _indexFromScreenType(screenType);
    if(_currentIndex == index) {
      return;
    }
    currentIndex = index;
    currentScreen = screenType;
    hasBottomBar = _hasBottomBarFromScreenType(screenType);
  }

  //TODO remove switches, add new classes

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

  void _screenNavigationCallback(ChatMainScreenType screenType) {
    switch (screenType) {
      case ChatMainScreenType.SIGN_IN_SCREEN:
        break;
      case ChatMainScreenType.SIGN_UP_SCREEN:
        break;
      case ChatMainScreenType.CHATS_SCREEN:
        break;
      case ChatMainScreenType.USER_SCREEN:
        break;
      case ChatMainScreenType.MAIN_LOADING_SCREEN:
        break;
    }
  }
}