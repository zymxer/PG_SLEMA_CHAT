import 'package:flutter/material.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository.dart';
import 'package:pg_slema/features/settings/presentation/widget/setting_text.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:provider/provider.dart';

class ChangeChatServiceAddressSettingText extends StatefulWidget {
  const ChangeChatServiceAddressSettingText({super.key});

  @override
  State<StatefulWidget> createState() => ChangeChatServiceAddressSettingTextState();
}

class ChangeChatServiceAddressSettingTextState
    extends State<ChangeChatServiceAddressSettingText> with Logger {
  late String currentValue;

  @override
  void initState() {
    super.initState();
    currentValue =
        Provider.of<ApplicationInfoRepository>(context, listen: false)
            .getChatServiceAddress();
  }

  @override
  Widget build(BuildContext context) {
    return SettingText(
      label: "Adres usługi czatów",
      initialValue: currentValue,
      onConfirmPressed: (newValue) => onConfirmPressed(context, newValue),
    );
  }

  void onConfirmPressed(BuildContext context, String newValue) {
    logger.debug("Setting chat service address value: $newValue.");
    Provider.of<ApplicationInfoRepository>(context, listen: false)
        .setChatServiceAddress(newValue);

    setState(() {
      currentValue = newValue;
    });
  }
}
