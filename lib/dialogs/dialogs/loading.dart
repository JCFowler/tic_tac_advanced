import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../helpers/translate_helper.dart';
import '../base_dialog_components.dart';

Future<dynamic> showLoadingDialog(BuildContext context, String title) {
  return basicDialogComponent(
    context,
    usePadding: false,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SpinKitRipple(
              size: 90,
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.red : Colors.blue,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.only(
            right: 20,
            left: 20,
          ),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        dialogBottomSubmitButtonComponent(
          text: translate('cancel'),
          onPressed: () {
            Navigator.pop(context, 'cancel');
          },
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      ],
    ),
  );
}
