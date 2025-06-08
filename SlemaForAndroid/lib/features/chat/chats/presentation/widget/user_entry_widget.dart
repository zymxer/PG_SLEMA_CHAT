import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/utils/widgets/default_container/default_container.dart';

class UserEntryWidget extends StatefulWidget {
  final User user;
  final void Function(User) onTap;

  @override
  State<StatefulWidget> createState() => UserEntryWidgetState();

  UserEntryWidget({ required this.user, required this.onTap, super.key});
}

  class UserEntryWidgetState extends State<UserEntryWidget> {

  bool isSelected = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultContainer(
        child: ElevatedButton(
            onPressed: _onPressed,
            style: ButtonStyle(

              padding: WidgetStateProperty.all(EdgeInsets.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,


              // 3. Disable hover/focus effects
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,

              // 4. Your existing color logic
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  return isSelected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.primaryContainer;
                },
              ),

              // Remove elevation effects
              elevation: WidgetStateProperty.all(0),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.account_box,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    )),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                )),
              ],
            )));
  }

  void _onPressed() {
    setState(() {
      isSelected = !isSelected; // Toggle selection state
    });
    widget.onTap(widget.user);
  }
}
