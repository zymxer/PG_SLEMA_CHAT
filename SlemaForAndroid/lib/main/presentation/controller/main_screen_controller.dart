import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_in_screen_new.dart';


import 'package:pg_slema/features/chat/auth/presentation/screen/signin_screen.dart';
import 'package:pg_slema/features/chat/main/presentation/screen/chat_main_screen.dart';

class MainScreenController extends ChangeNotifier {
  int _currentIndex = 1;

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  final PageController pageController = PageController();

  void onTabTapped(int index) {
    currentIndex = index;
  }

  void onChatsTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatMainScreen(),
      ),
    );
  }
}
