import 'package:flutter/material.dart';

class CalendarMoveBackward extends StatelessWidget {
  final VoidCallback? onPressed;

  const CalendarMoveBackward({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.arrow_back,
        shadows: [Shadow(color: Colors.transparent)],
      ),
      style: Theme.of(context).iconButtonTheme.style?.copyWith(
            iconColor: WidgetStateProperty.resolveWith((states) {
              if (!states.contains(WidgetState.disabled)) {
                return Theme.of(context).colorScheme.onPrimary;
              }
              return Theme.of(context).colorScheme.onPrimary.withOpacity(0.2);
            }),
            iconSize: const WidgetStatePropertyAll(30),
          ),
      onPressed: onPressed,
    );
  }
}
