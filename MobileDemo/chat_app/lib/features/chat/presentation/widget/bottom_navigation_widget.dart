
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  late String currentRoute;
  final List<String> routes = [
    "/signIn",
    "/inbox",
    "/account"
  ];
  int _currentIndex = 0;


  BottomNavigationWidget(String currentRoute, {super.key}) {
    this.currentRoute = currentRoute;
    _currentIndex = indexFromRoute(currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indexFromRoute(currentRoute),
      onTap: (index) {
        _onTap(index, context);
      },
      items: [
        BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.home)
        ),
        BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.chat_bubble)
        ),
        BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.account_box)
        )
      ],
    );
  }

  void _onTap(int index, BuildContext context) {
    if(index != _currentIndex) {
      Navigator.pushNamed(context, routes[index]);
    }
  }
  
  int indexFromRoute(String route) {
    return routes.indexOf(route);
  }

}