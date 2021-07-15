import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<dynamic> showCustomDialog(BuildContext context) async {
  final _form = GlobalKey<FormState>();

  String? enteredText;

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Please enter a new username'),
              Form(
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
              ElevatedButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    _form.currentState!.save();
                    Navigator.pop(context, enteredText);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    40,
                  ),
                ),
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<dynamic> showCustomLoadingDialog(
    BuildContext context, String title, bool show) async {
  if (!show) return;
  await showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SpinKitFadingGrid(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.red : Colors.blue,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, null);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
