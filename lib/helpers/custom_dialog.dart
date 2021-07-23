import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<T?> _basicDialog<T extends Object?>(
  BuildContext context, {
  required Widget child,
  usePadding = true,
}) {
  return showGeneralDialog(
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: false,
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (dialogContext, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: Dialog(
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
      );
    },
  );
}

Widget _bottomSubmitButton({
  required String text,
  required Function onPressed,
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
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: textColor ?? textColor,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Future<dynamic> showCustomDialog(BuildContext context) async {
  final _form = GlobalKey<FormState>();

  String? enteredText;

  return _basicDialog(
    context,
    usePadding: false,
    child: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FittedBox(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'New username',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).errorColor,
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(10)),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Form(
            key: _form,
            child: TextFormField(
                onSaved: (value) => enteredText = value,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value != null && value.length > 3) {
                    return null;
                  } else {
                    return 'Username has to be 4 or more characters.';
                  }
                }),
          ),
        ),
        _bottomSubmitButton(
          text: 'Finish',
          onPressed: () {
            if (_form.currentState!.validate()) {
              _form.currentState!.save();
              Navigator.pop(context, enteredText);
            }
          },
        ),
      ],
    ),
  );
}

Future<dynamic> showAlertDialog(
  BuildContext context,
  String title, {
  String? content,
  yesBtn = 'Yes',
  noBtn = 'No',
}) {
  return _basicDialog(
    context,
    child: Column(
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).primaryColor,
            )),
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )),
          ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Future<dynamic> showLoadingDialog(BuildContext context, String title) {
  return _basicDialog(
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
        _bottomSubmitButton(
          text: 'Cancel',
          onPressed: () {
            Navigator.pop(context, 'cancel');
          },
          backgroundColor: Theme.of(context).errorColor,
        ),
      ],
    ),
  );
}
