import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';

class ChatNavigationDestination extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ChatMainScreenType currentSelectedScreen;
  final ChatMainScreenType? destinationScreen;
  final void Function(ChatMainScreenType) onPressed;
  final void Function()? onHomePressed;

  const ChatNavigationDestination({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onPressed,
    required this.currentSelectedScreen,
    required this.destinationScreen,
    this.onHomePressed,
  });

  @override
  ChatNavigationDestinationState createState() =>
      ChatNavigationDestinationState();
}

class ChatNavigationDestinationState
    extends State<ChatNavigationDestination> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      isSelected: widget.destinationScreen == widget.currentSelectedScreen,
      selectedIcon: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Icon(
            widget.selectedIcon,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      icon: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(
            widget.icon,
            size: 48,
          )),
      tooltip: widget.label,
      onPressed: () {
        widget.onPressed(widget.destinationScreen ?? widget.currentSelectedScreen);
        if(widget.onHomePressed != null) {
          widget.onHomePressed!();
        }

      },
    );
  }
}
