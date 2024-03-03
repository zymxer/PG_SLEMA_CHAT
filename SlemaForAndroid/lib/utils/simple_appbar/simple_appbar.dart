import 'package:flutter/material.dart';

class SimpleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const SimpleAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
        ), // TODO Icon has padding of 8.0. Result? Text not aligned.
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
      ),
      iconTheme: Theme.of(context)
          .iconTheme
          .copyWith(color: Theme.of(context).colorScheme.onPrimary, size: 38),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
