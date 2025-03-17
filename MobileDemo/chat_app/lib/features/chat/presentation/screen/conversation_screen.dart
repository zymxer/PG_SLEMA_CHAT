import 'package:chat_app/features/chat/logic/entity/chat.dart';
import 'package:chat_app/features/chat/logic/entity/message.dart';
import 'package:chat_app/features/chat/logic/entity/post_message_request.dart';
import 'package:chat_app/features/chat/logic/service/chat_service.dart';
import 'package:chat_app/features/chat/presentation/widget/message_widget.dart';
import 'package:chat_app/features/user/logic/entity/user.dart';
import 'package:chat_app/features/user/logic/service/user_service.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});


  @override
  State<StatefulWidget> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  late Future<List<Message>> messages;
  late Chat chat;
  final ChatService chatService = ChatService();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    chat = ModalRoute.of(context)!.settings.arguments as Chat;
    messages = chatService.getChatMessages(chat.id);

    return Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: size.height / 15,
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () { Navigator.pushNamed(context, "/inbox"); } ,
                    icon: Icon(Icons.arrow_back)
                ),
                Text(
                    chat.name,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    )
                )
              ],
            ),
            FutureBuilder<List<Message>>(  // Specify the type of data you're expecting
              future: messages,  // Assuming `users` is a Future<List<UserDto>>
              builder: (context, snapshot) {
                // Check if the future is still loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                      child: Center(
                          child: CircularProgressIndicator()
                      )
                  );  // Show loading spinner
                }

                // Handle error state
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));  // Show error message
                }

                // Handle success state, when data is available
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  List<Message> messages = snapshot.data!;  // Extract the data (make sure to handle null safety)

                  return Expanded(
                    child: ListView.separated(
                      itemCount: messages.length,
                      separatorBuilder: (context, index) => SizedBox(height: 20,),
                      itemBuilder: (context, index) {
                        return MessageWidget(messages[index], size);
                      },
                    ),
                  );
                }

                // Fallback if data is null
                return Center(child: Text("No data available"));
              },
            ),
            SizedBox(
              height: size.height / 6,
              width: size.width / 1.2,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async{
                      chatService.sendMessage(PostMessageRequest(chat, messageController.text));
                      var tempList = await messages;
                      User.currentUser = await UserService().getCurrentUser();
                      tempList.add(Message("UNDEFINED", messageController.text, User.currentUser!.id));
                      messages = Future.value(tempList);
                      setState(() {

                      });
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),

    );
  }

  Widget field(Size size, String hintText, IconData icon, bool obscureText,
      TextEditingController? controller) {
    return SizedBox(
      height: size.height / 15,
      width: size.width / 1.2,
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
      ),
    );
  }
}