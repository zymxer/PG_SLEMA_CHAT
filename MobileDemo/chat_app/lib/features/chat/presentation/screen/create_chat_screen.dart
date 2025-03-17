import 'package:chat_app/features/chat/logic/entity/create_chat_request.dart';
import 'package:chat_app/features/chat/logic/service/chat_service.dart';
import 'package:chat_app/features/chat/presentation/widget/bottom_navigation_widget.dart';
import 'package:chat_app/features/user/logic/entity/user.dart';
import 'package:chat_app/features/user/logic/service/user_service.dart';
import 'package:flutter/material.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});


  @override
  State<StatefulWidget> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  late Future<List<User>> users;
  final List<User> selectedUsers = [];
  final UserService userService = UserService();
  final ChatService chatService = ChatService();

  @override
  void initState() {

    users = userService.getAllUsers();

    super.initState();
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
                  Row(
                    children: [
                      IconButton(
                          onPressed: () { Navigator.pop(context); } ,
                          icon: Icon(Icons.arrow_back)
                      ),
                      Text(
                          "Create new chat",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          )
                      ),

                    ],
                  ),
                  Container(
                    width: size.width / 1.2,
                    alignment: Alignment.center,
                    child: field(size, "Find user", Icons.search, false, null),
                  ),
                  FutureBuilder<List<User>>(  // Specify the type of data you're expecting
                    future: users,  // Assuming `users` is a Future<List<UserDto>>
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
                        List<User> users = snapshot.data!;  // Extract the data (make sure to handle null safety)

                        return Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(Icons.account_box), // Profile pic
                                title: Text(users[index].name), // Name
                                onTap: () => _onUserTap(users, index),
                                trailing: Icon(
                                  selectedUsers.contains(users[index]) ? Icons.check_box : Icons.check_box_outline_blank,
                                ),
                              );
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
                  onPressed: () async{
                    if (selectedUsers.isNotEmpty) {
                      User.currentUser = await UserService().getCurrentUser();
                      await chatService.createChat(CreateChatRequest(
                        "${selectedUsers[0].name} and ${User.currentUser!.name}", 0, selectedUsers[0].name));
                    }
                    Navigator.pop(context);
                  },
                  child: Icon(
                      Icons.check
                  ),
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

  void _onUserTap(List<User> users, int index) {
    setState(() {
      if (selectedUsers.contains(users[index])) {
        selectedUsers.remove(users[index]); // Deselect
      } else {
        selectedUsers.add(users[index]); // Select
      }
    });
  }

}