import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/dialogs/how_to_play.dart';
import '../dialogs/dialogs/settings.dart';
import '../helpers/radiant_gradient_mask.dart';
import '../helpers/translate_helper.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';

enum PopUpSelection { howToPlay, restart, resign }

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool gameScreen;
  final String? title;
  final Function? onTap;
  final Color? backgroundColor;

  const GameAppBar({
    Key? key,
    this.gameScreen = false,
    this.onTap,
    this.title,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(gameScreen ? 40 : 55);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return AppBar(
      title: title != null
          ? GestureDetector(
              onTap: onTap != null ? () => onTap!() : null,
              child: FittedBox(
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
      centerTitle: true,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: gameScreen ? Colors.black87 : Colors.white,
      ),
      actions: _getActions(
        context,
        userProvider,
        gameProvider,
        localeProvider,
      ),
    );
  }

  List<Widget> _getActions(
    BuildContext context,
    UserProvider userProvider,
    GameProvider gameProvider,
    LocaleProvider localeProvider,
  ) {
    if (gameScreen) {
      // ONLY inside game screen
      return [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          onSelected: (PopUpSelection selectedValue) {
            switch (selectedValue) {
              case PopUpSelection.howToPlay:
                showHowToPlayDialog(context);
                break;
              case PopUpSelection.restart:
                gameProvider.gameRestart();
                break;
              case PopUpSelection.resign:
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: PopUpSelection.howToPlay,
              child: Text(translate('howToPlay')),
            ),
            if (gameProvider.gameDoc.isEmpty)
              PopupMenuItem(
                value: PopUpSelection.restart,
                child: Text(translate('restart')),
              )
            // gameProvider.gameDoc.isNotEmpty
            //     ? PopupMenuItem(
            //         child: Text(translate('resign')),
            //         value: PopUpSelection.resign,
            //       )
            //     : PopupMenuItem(
            //         child: Text(translate('restart')),
            //         value: PopUpSelection.restart,
            //       )
          ],
        ),
      ];
    }

    // Everywhere in app
    return [
      IconButton(
        onPressed: () => showHowToPlayDialog(context),
        alignment: Alignment.topCenter,
        icon: Icon(
          Icons.help_outline,
          size: 35,
          color: Colors.blue.shade50,
        ),
      ),
      RadiantGradientMask(
        colors: const [
          Color(0xfff5f7fa),
          Color(0xffb8c6db),
          Color(0xfff5f7fa),
        ],
        child: IconButton(
          onPressed: () => showSettingsDialog(
            context,
            userProvider,
            localeProvider,
          ),
          alignment: Alignment.topCenter,
          icon: Icon(
            Icons.settings,
            size: 35,
            color: Colors.blue.shade50,
          ),
        ),
      ),
    ];
  }
}
