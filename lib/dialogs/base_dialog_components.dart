import 'package:flutter/material.dart';

import '../helpers/translate_helper.dart';

Future<T?> basicDialogComponent<T extends Object?>(
  BuildContext context, {
  required Widget child,
  bool? barrierDismissible,
  EdgeInsets outSidePadding = const EdgeInsets.symmetric(
    horizontal: 40.0,
    vertical: 24.0,
  ),
  usePadding = true,
}) {
  return showGeneralDialog(
    transitionDuration: const Duration(milliseconds: 200),
    context: context,
    barrierDismissible: barrierDismissible ?? false,
    barrierLabel: barrierDismissible != null ? 'Dismissable' : null,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (dialogContext, a1, a2, widget) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              clipBehavior: Clip.hardEdge,
              insetPadding: outSidePadding,
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                children: [
                  usePadding
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            right: 20,
                            left: 20,
                            bottom: 5,
                          ),
                          child: child,
                        )
                      : child
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget dialogBottomSubmitButtonComponent({
  required String text,
  required Function onPressed,
  bool loading = false,
  Color? backgroundColor,
  Color? textColor,
}) {
  return ElevatedButton(
    onPressed: () => onPressed(),
    style: ElevatedButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      minimumSize: const Size(
        double.infinity,
        40,
      ),
      primary: backgroundColor ?? backgroundColor,
    ),
    child: loading
        ? const FittedBox(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: textColor ?? textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
  );
}

Widget dialogHeaderComponent(BuildContext context, String title) {
  return SizedBox(
    height: 32,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              translate(title),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              size: 30,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
