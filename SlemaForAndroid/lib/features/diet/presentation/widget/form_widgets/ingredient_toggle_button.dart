import 'package:flutter/material.dart';

class IngredientToggleButton extends StatefulWidget {
  final String label;
  final VoidCallback onTogglePressed;
  final bool isToggledOn;
  const IngredientToggleButton(
      {super.key,
      required this.label,
      required this.onTogglePressed,
      required this.isToggledOn});

  @override
  State<IngredientToggleButton> createState() => _IngredientToggleButtonState();
}

class _IngredientToggleButtonState extends State<IngredientToggleButton> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle standardTheme = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(10, 10)),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 2, horizontal: 12)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));

    ButtonStyle unselectedTheme = standardTheme.copyWith(
      foregroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
      backgroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
      textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelSmall!.copyWith(height: 1.0)),
    );

    ButtonStyle selectedTheme = standardTheme.copyWith(
      foregroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
      backgroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
      textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelSmall!.copyWith(height: 1.0)),
    );

    return SizedBox(
      height: 25,
      child: OutlinedButton(
        style: widget.isToggledOn ? selectedTheme : unselectedTheme,
        onPressed: widget.onTogglePressed,
        child: Text(widget.label),
      ),
    );
  }
}
