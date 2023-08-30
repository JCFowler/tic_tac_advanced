import 'package:flutter/material.dart';
import 'package:tic_tac_advanced/helpers/translate_helper.dart';

import '../base_dialog_components.dart';

showHowToPlayDialog(BuildContext context, {firstTime = false}) {
  final deviceSize = MediaQuery.of(context).size;
  String bullet = "\u2022";

  return basicDialogComponent(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    usePadding: false,
    child: Padding(
      padding: const EdgeInsets.only(
        right: 20,
        left: 20,
      ),
      child: SizedBox(
        height: deviceSize.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              dialogHeaderComponent(context, 'howToPlay'),
              Divider(
                thickness: 1.5,
                color: Theme.of(context).primaryColor,
              ),
              _text(context, translate('htpTitleOverview'), isTitle: true),
              _text(context, translate('htpOne')),
              SizedBox(
                height: deviceSize.height * 0.2,
                child: Image.asset(
                  'assets/images/how-to-play-1.png',
                  fit: BoxFit.contain,
                ),
              ),
              _text(context, translate('htpTitleMoves'), isTitle: true),
              _text(context, '$bullet ${translate('howToMoveOne')}'),
              _text(context, '$bullet ${translate('howToMoveTwo')}'),
              SizedBox(
                height: deviceSize.height * 0.1,
                child: Image.asset(
                  'assets/images/how-to-play-2.png',
                  fit: BoxFit.contain,
                ),
              ),
              _text(context, translate('htpTitleTips'), isTitle: true),
              _text(context, '$bullet ${translate('tipOne')}'),
              _text(context, '$bullet ${translate('tipTwo')}'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _text(BuildContext context, String text, {bool isTitle = false}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: isTitle
          ? const EdgeInsets.only(top: 10, bottom: 2)
          : const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          color:
              isTitle ? Theme.of(context).secondaryHeaderColor : Colors.black,
          fontSize: isTitle ? 20 : 16,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}
