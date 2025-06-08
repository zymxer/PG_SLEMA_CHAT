import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/add_chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/user_entry_widget.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body_with_floating_action_button.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body_with_multiple_floating_action_buttons.dart';
import 'package:pg_slema/utils/widgets/default_floating_action_button/default_floating_action_button.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class AddChatScreenConfirm extends StatefulWidget {

  AddChatScreenConfirm({super.key});

  @override
  State<StatefulWidget> createState() => AddChatScreenConfirmState();
}

class AddChatScreenConfirmState extends State<AddChatScreenConfirm> {
  @override
  void initState() {
    super.initState();
    Provider.of<AddChatController>(context, listen: false).fetchUsers();
    print("In init state");
  }

  Widget build(BuildContext context) {
    final controller = Provider.of<AddChatController>(context);

    return Scaffold(
      body: Column(
        children: [
          DefaultAppBar(title: "Zatwierdź"),
          DefaultBodyWithMultipleFloatingActionButtons(
            buttons: [(() => controller.createChat(), Icons.check)],
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    CustomTextFormField(
                      label: "Nazwa konwersacji",
                      initialValue: controller.search,
                      icon: Icons.search,
                      onChanged: (value) => controller.search = value,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.selected.length,
                      itemBuilder: (context, index) {
                        final user = controller.selected[index];
                        return UserEntryWidget(
                          user: user,
                          onTap: controller.onUserTap,
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return const SizedBox(height: 20);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
