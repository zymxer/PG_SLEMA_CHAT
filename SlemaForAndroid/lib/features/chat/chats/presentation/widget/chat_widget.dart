import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/medicine/logic/entity/medicine.dart';
import 'package:pg_slema/features/medicine/presentation/widget/all_medicines_screen/single_medicine_label.dart';
import 'package:pg_slema/features/medicine/presentation/widget/all_medicines_screen/medicine_popup_menu_edit_delete_button.dart';
import 'package:pg_slema/utils/widgets/default_container/default_container.dart';

//from SingleMedicineWidget
// TODO stateful for message preview updates
class ChatWidget extends StatelessWidget {

  final Chat chat;

  const ChatWidget({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultContainer(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.telegram,
                color: Theme.of(context).primaryColor,
                size: 40,
              )
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32,
                    child:
                    Text(
                      chat.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: Text(
                      "Message preview",
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  )

                ],
              )
          ),
        ],
      ),
    );
  }
}
