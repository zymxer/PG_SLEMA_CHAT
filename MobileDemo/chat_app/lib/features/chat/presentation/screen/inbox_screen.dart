import 'package:chat_app/features/chat/logic/entity/chat.dart';
import 'package:chat_app/features/chat/logic/service/chat_service.dart';
import 'package:chat_app/features/chat/presentation/widget/bottom_navigation_widget.dart';
import 'package:chat_app/features/chat/presentation/widget/chat_widget.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});


  @override
  State<StatefulWidget> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<Chat>> chats;
  final ChatService chatService = ChatService();

  @override
  void initState() {

    _fetchData();

    super.initState();
  }

  void _fetchData() async {
    chats = chatService.getAllChats();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
        body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: size.height / 15,
                  ),
                  Container(
                    width: size.width / 3,
                    height: size.height / 10,
                    alignment: Alignment.center,
                    child: Text(
                      "Chats",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                      width: size.width / 1.2,
                      height: size.height / 20,
                      alignment: Alignment.center,
                      child: field(size, "Search", Icons.search, false, null)
                  ),
                  FutureBuilder<List<Chat>>(  // Specify the type of data you're expecting
                    future: chats,  // Assuming `users` is a Future<List<UserDto>>
                    builder: (context, snapshot) {
                      // Check if the future is still loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());  // Show loading spinner
                      }

                      // Handle error state
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));  // Show error message
                      }

                      // Handle success state, when data is available
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        List<Chat> chats = snapshot.data!;  // Extract the data (make sure to handle null safety)

                        return Expanded(
                          child: ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return ChatWidget(chat: chats[index]);
                            },
                          ),
                        );
                      }

                      // Fallback if data is null
                      return Center(child: Text("No data available"));
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 20, // Adjust this to position it above the BottomNavigationBar
                right: 20,  // Adjust this to place it in the right corner
                child: FloatingActionButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, "/create_chat")
                        .then((result) {
                          setState(() {
                            _fetchData();
                          });
                        }
                        );
                    },
                  child: Icon(Icons.add),
                ),
              ),
            ]
        ),
        bottomNavigationBar: BottomNavigationWidget("/inbox")
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