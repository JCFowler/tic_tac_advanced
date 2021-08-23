import 'package:flutter/material.dart';

import '../../helpers/translate_helper.dart';
import '../../widgets/primary_button.dart';
import '../base_dialog_components.dart';

Future<bool?> showAlertDialog(
  BuildContext context,
  String title, {
  String? content,
  bool barrierDismissible = true,
  bool singleButton = false,
  String yesBtnText = 'yes',
  String noBtnText = 'no',
}) {
  yesBtnText = translate(yesBtnText);
  noBtnText = translate(noBtnText);

  return basicDialogComponent(
    context,
    barrierDismissible: barrierDismissible,
    child: Column(
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).accentColor,
            )),
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )),
          ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (!singleButton)
              PrimaryButton(
                noBtnText,
                expanded: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            PrimaryButton(
              yesBtnText,
              expanded: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}
