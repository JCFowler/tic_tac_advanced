import 'package:flutter/material.dart';

import '../../helpers/translate_helper.dart';
import '../../widgets/primary_button.dart';
import '../base_dialog_components.dart';

Future<bool?> showNewUpdateDialog(BuildContext context) {
  return basicDialogComponent(
    context,
    barrierDismissible: false,
    child: Column(
      children: [
        Text(translate('newUpdate'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).secondaryHeaderColor,
            )),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(translate('goDownload'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              )),
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          translate('download'),
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}
