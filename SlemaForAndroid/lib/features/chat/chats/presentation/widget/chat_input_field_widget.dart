import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final bool isValueRequired;
  final VoidCallback? onPostfixPressed; // New callback for postfix button
  final IconData? postfixIcon; // Icon for postfix button
  final TextEditingController textEditingController;

  const ChatInputField({
    required this.textEditingController,
    this.label,
    this.icon,
    this.initialValue,
    this.onPostfixPressed,
    super.key,
    required this.onChanged,
    this.isValueRequired = true,
    this.postfixIcon = Icons.send,
  });

  @override
  State<ChatInputField> createState() => ChatInputFieldState();
}

class ChatInputFieldState extends State<ChatInputField> {
  final double defaultTextBottomPadding = 0.0;
  final double borderWidth = 2.5;
  final double borderRadius = 18.0;
  final double labelFontSize = 24.0;
  final double prefixIconSize = 38.0;
  final double prefixIconPaddingWidth = 12.0;
  final double verticalDividerWidth = 2.0;
  final double verticalDividerBoxHeight = 33.0;
  late double prefixBoxWidth;

  @override
  void initState() {
    prefixBoxWidth =
        prefixIconSize + prefixIconPaddingWidth + verticalDividerWidth + 14.0;
    super.initState();
  }

  String? validateInput(String? value) {
    if (widget.isValueRequired && (value == null || value.trim().isEmpty)) {
      return 'Proszę uzupełnić to pole';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
        maxHeight: 120,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: TextFormField(
                  controller: widget.textEditingController,
                  initialValue: widget.initialValue,
                  validator: validateInput,
                  onChanged: widget.onChanged,
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium?.fontSize,
                    height: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    border: InputBorder.none,
                    label: widget.label != null
                        ? Padding(
                            padding: EdgeInsets.only(
                                bottom: defaultTextBottomPadding),
                            child: Text(widget.label!),
                          )
                        : null,
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                widget.postfixIcon,
                color: Theme.of(context).primaryColor,
                size: 32, // Slightly larger icon for better touch area
              ),
              onPressed: widget.onPostfixPressed,
              //padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
    );
  }
}
