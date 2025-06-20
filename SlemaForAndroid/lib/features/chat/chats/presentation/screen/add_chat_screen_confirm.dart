import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/add_chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/user_entry_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class AddChatScreenConfirm extends StatefulWidget {
  AddChatScreenConfirm({super.key});

  @override
  State<StatefulWidget> createState() => AddChatScreenConfirmState();
}

class AddChatScreenConfirmState extends State<AddChatScreenConfirm> {
  late TextEditingController _chatNameController;

  @override
  void initState() {
    super.initState();
    _chatNameController = TextEditingController();

    final controller = Provider.of<AddChatController>(context, listen: false);
    if (controller.selected.length > 1) {
      _chatNameController.text = "Grupowy chat";
    }
    print("In init state of AddChatScreenConfirmState");
  }

  @override
  void dispose() {
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AddChatController>(context);

    return Scaffold(
      appBar: DefaultAppBar(title: "Zatwierdź"),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? chatNameForGroup = controller.selected.length > 1 ? _chatNameController.text : null;
          bool success = await controller.createChat(chatNameForGroup);
          if (success) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nie udało się stworzyć chat.')),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
      body: DefaultBody(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                if (controller.selected.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: CustomTextFormField(
                      label: "Nazwa konwersacji",
                      initialValue: _chatNameController.text,
                      icon: Icons.edit,
                      onChanged: (value) {
                        _chatNameController.text = value;
                      },
                      isValueRequired: true,
                    ),
                  ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}