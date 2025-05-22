import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserInformationWidget extends StatefulWidget {

  // user Screen controller
  final IconData icon;
  final String headerText;
  final String footerText;

  const UserInformationWidget({
    super.key,
    required this.icon,
    required this.headerText,
    required this.footerText
  });
  @override
  State<StatefulWidget> createState() => _UserInformationWidgetState();
}

class _UserInformationWidgetState extends State<UserInformationWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              widget.icon,
              color: Theme.of(context).primaryColor,
              size: 40,
            )
        ),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  child:
                  Text(
                    widget.headerText,
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: Text(
                    widget.footerText,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                )
              ],
            )
        ),
      ],
    );
  }
}