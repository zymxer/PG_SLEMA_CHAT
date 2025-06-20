import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/add_chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/user_entry_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body_with_multiple_floating_action_buttons.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class AddChatScreen extends StatefulWidget {
  AddChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => AddChatScreenState();
}

class AddChatScreenState extends State<AddChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddChatController>(context, listen: false).fetchUsers();
    });
    print("In init state");
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AddChatController>(context);

    return Scaffold(
      appBar: DefaultAppBar(title: "Dodaj czat"),
      body: DefaultBodyWithMultipleFloatingActionButtons(
        buttons: [
          (() async {
            bool success = await controller.createChat();
            if (success) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nie udało się stworzyć chat.')),
              );
            }
          }, Icons.check)
        ],
        child: Column(children: [
          const SizedBox(height: 20.0),
          CustomTextFormField(
            label: "Szukaj użytkownika",
            initialValue: controller.search,
            icon: Icons.search,
            onChanged: (value) => controller.search = value,
          ),
          Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return UserEntryWidget(
                    user: user,
                    onTap: controller.onUserTap,
                  );
                },
                separatorBuilder: (context, int index) {
                  return const SizedBox(height: 20);
                },
              ))
        ]),
      ),
    );
  }
}