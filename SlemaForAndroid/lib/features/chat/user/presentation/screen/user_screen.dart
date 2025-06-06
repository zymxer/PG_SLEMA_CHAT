import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_up_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/widget/auth_button.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/chat/user/presentation/widget/user_information_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/appbars/white_app_bar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {


  const UserScreen({
    super.key,
  });
  @override
  State<StatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mainScreenController = Provider.of<ChatMainScreenController>(context);
    final userService = Provider.of<UserService>(context);

    return Column(
      children: [
        const WhiteAppBar(titleText: "Profil użytkownika"),
        DefaultBody(
        child: SingleChildScrollView(
              child: Column(
                children: [
                  // TODO Profile pic
                  //images from lib/features/picture/presentation/widget/picture_list.dart
                  Icon(
                    Icons.telegram,
                    color: Theme.of(context).primaryColor,
                    size: 160,  // TODO check for screens with lower resolution
                  ),
                  UserInformationWidget(
                      icon: Icons.account_box,
                      headerText: "CoolUserName",
                      footerText: "Nazwa użytkownika"),
                  const SizedBox(height: 20.0),
                  UserInformationWidget(
                      icon: Icons.account_box,
                      headerText: "Moje imię",
                      footerText: "Imię"),
                  const SizedBox(height: 20.0),
                  UserInformationWidget(
                      icon: Icons.info,
                      headerText: "O siebie",
                      footerText: "Używam aplikację SLEMA"),
                ],
              ),
            ),
          )
      ],
    );
  }
  void _onFieldChangedPlaceholder(String name) {
    //TODO replace
  }

  void _onButtonPressedPlaceholder() {
    // TODO replace
  }

}