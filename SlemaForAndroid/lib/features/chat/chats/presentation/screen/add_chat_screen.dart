import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/add_chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/user_entry_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class AddChatScreen extends StatefulWidget {
  AddChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => AddChatScreenState();
}

class AddChatScreenState extends State<AddChatScreen> {
  late TextEditingController _groupChatNameController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddChatController>(context, listen: false).fetchUsers();
    });
    _groupChatNameController = TextEditingController();
    print("In init state of AddChatScreenState");
  }

  @override
  void dispose() {
    _groupChatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AddChatController>(context);

    return Scaffold(
      appBar: DefaultAppBar(title: "Dodaj czat"),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? chatNameForGroup;
          if (controller.selected.length > 1) {
            chatNameForGroup = _groupChatNameController.text;
            if (chatNameForGroup.trim().isEmpty) {
              chatNameForGroup = "Grupowy chat";
            }
          }

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
        child: Column(children: [
          const SizedBox(height: 20.0),
          CustomTextFormField(
            label: "Szukaj użytkownika",
            initialValue: controller.search,
            icon: Icons.search,
            onChanged: (value) => controller.search = value,
          ),

          if (controller.selected.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: TextFormField(
                controller: _groupChatNameController,
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: InputDecoration(
                  labelText: "Nazwa chatu grupowego",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                onChanged: (value) {
                },
              ),
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