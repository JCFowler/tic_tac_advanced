import 'package:flutter/material.dart';

import '../../helpers/translate_helper.dart';
import '../../providers/user_provider.dart';
import '../../services/fire_service.dart';
import '../../widgets/username_text_field.dart';
import '../base_dialog_components.dart';

Future<dynamic> showChangeUsernameDialog(
  BuildContext context, {
  FireService? fireService,
  UserProvider? userProvider,
}) async {
  final _form = GlobalKey<FormState>();

  String? enteredText;
  bool duplicate = false;
  bool loading = false;

  return basicDialogComponent(
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      translate('changeUsername'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).errorColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                  ),
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
          child: UsernameTextField(
            formKey: _form,
            onSaved: (value) => enteredText = value,
            duplicate: () => duplicate,
          ),
        ),
        StatefulBuilder(builder: (context, setState) {
          return dialogBottomSubmitButtonComponent(
            text: translate('finished'),
            loading: loading,
            onPressed: () async {
              duplicate = false;
              if (_form.currentState!.validate()) {
                _form.currentState!.save();
                setState(() {
                  loading = true;
                });
                if (await fireService!.doesUsernameExist(enteredText!)) {
                  duplicate = true;
                  _form.currentState!.validate();
                  setState(() {
                    loading = false;
                  });
                } else {
                  userProvider!.updateUsername(enteredText!).then(
                        (value) => Navigator.pop(context, enteredText),
                      );
                }
              }
            },
          );
        }),
      ],
    ),
  );
}
