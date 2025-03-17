import 'package:chat_app/features/auth/presentation/screen/signin_screen.dart';
import 'package:chat_app/features/auth/presentation/screen/signup_screen.dart';
import 'package:chat_app/features/chat/presentation/screen/conversation_screen.dart';
import 'package:chat_app/features/chat/presentation/screen/create_chat_screen.dart';
import 'package:chat_app/features/chat/presentation/screen/inbox_screen.dart';
import 'package:chat_app/features/user/logic/entity/user.dart';
import 'package:chat_app/features/user/logic/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  await dotenv.load(fileName: ".env");
  User.currentUser = await UserService().getCurrentUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final bool loggedOn = User.currentUser == null ? false : true;
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: loggedOn ? "/inbox" : "/signIn",
      routes: {
        "/signIn": (context) => SignInScreen(), //todo static routes in Screen classes
        "/signUp": (context) => SignUpScreen(),
        "/inbox": (context) => InboxScreen(),
        "/conversation": (context) => ConversationScreen(),
        "/create_chat" : (context) => CreateChatScreen()
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
