import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_advanced/helpers/radiant_gradient_mask.dart';

import '../helpers/custom_dialog.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool gameScreen;
  final String? title;
  final Function? onTap;

  const GameAppBar({
    Key? key,
    this.gameScreen = false,
    this.onTap,
    this.title,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(gameScreen ? 40 : 55);

  @override
  Widget build(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context);
    final _localeProvider = Provider.of<LocaleProvider>(context);

    return AppBar(
      title: title != null
          ? GestureDetector(
              onTap: onTap != null ? () => onTap!() : null,
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: gameScreen ? Colors.black87 : Colors.white,
      ),
      actions: [
        !gameScreen
            ? RadiantGradientMask(
                colors: const [
                  Color(0xfff5f7fa),
                  Color(0xffb8c6db),
                  Color(0xfff5f7fa),
                ],
                child: IconButton(
                  onPressed: () => showSettingsDialog(
                    context,
                    _userProvider,
                    _localeProvider,
                  ),
                  alignment: Alignment.topCenter,
                  icon: Icon(
                    Icons.settings,
                    size: 35,
                    color: Colors.blue[50],
                  ),
                ),
              )
            : IconButton(
                onPressed: () => showSettingsDialog(
                  context,
                  _userProvider,
                  _localeProvider,
                ),
                icon: const Icon(
                  Icons.settings,
                  size: 35,
                  color: Colors.black87,
                ),
              ),
      ],
    );
  }
}
