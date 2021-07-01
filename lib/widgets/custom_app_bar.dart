import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
      actions: [
        IconButton(
          onPressed:
              Provider.of<GameProvider>(context, listen: false).gameResart,
          icon: Icon(
            Icons.restart_alt,
          ),
        )
      ],
    );
  }
}
