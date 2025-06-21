import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/presentation/screen/chat_screen.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/utils/widgets/default_container/default_container.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  final Chat chat;

  ChatWidget(
      this.chat, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = Provider.of<ChatService>(context, listen: false);
    final UserService userService = Provider.of<UserService>(context, listen: false);
    final TokenService tokenService = Provider.of<TokenService>(context, listen: false);

    return DefaultContainer(
        padding: const EdgeInsets.only(bottom: 20),
        child: ElevatedButton(
          onPressed: () => _onPressed(context, chat),
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
                  )),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Text(
                          chat.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: Text(
                          "Podgląd wiadomości",
                          style: Theme.of(context).textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  )),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => _showDeleteOptions(
                  context,
                  chat,
                  chatService,
                  tokenService,
                ),
              ),
            ],
          ),
        ));
  }

  void _onPressed(BuildContext context, Chat chat) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
  }

  void _showDeleteOptions(
      BuildContext context,
      Chat chat,
      ChatService chatService,
      TokenService tokenService,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Usuń czat dla wszystkich',
              style: TextStyle(fontSize: 18)
                ,),

              onTap: () async {
                Navigator.pop(bc);
                await _deleteChatGlobally(context, chat, chatService, tokenService);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChatLocally(BuildContext context, Chat chat, ChatService chatService) async {
    try {
      chatService.removeChatLocally(chat.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Czat "${chat.name}" został usunięty lokalnie.'), duration: Duration(seconds: 2)),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('ChatWidget: Błąd podczas lokalnego usuwania czatu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania czatu lokalnie: $e'), duration: Duration(seconds: 3)),
      );
    }
  }

  Future<void> _deleteChatGlobally(BuildContext context, Chat chat, ChatService chatService, TokenService tokenService) async {
    try {
      final token = await tokenService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd: Brak tokenu autoryzacji.')),
        );
        return;
      }

      await chatService.deleteChat(chat.id, token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Czat "${chat.name}" został usunięty dla wszystkich.', style: TextStyle(fontSize: 18),), duration: Duration(seconds: 2)),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('ChatWidget: Błąd podczas globalnego usuwania czatu: $e');
      String errorMessage = 'Błąd podczas usuwania czatu dla wszystkich: $e';
      if (e.toString().contains("AuthenticationException")) {
        errorMessage = 'Nie masz uprawnień do usunięcia tego czatu dla wszystkich.';
      } else if (e.toString().contains("ResourceNotFoundException")) {
        errorMessage = 'Czat nie został znaleziony.';
      } else if (e.toString().contains("401") || e.toString().contains("403")) {
        errorMessage = 'Błąd dostępu: Sprawdź swoje uprawnienia lub token.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), duration: Duration(seconds: 3)),
      );
    }
  }
}