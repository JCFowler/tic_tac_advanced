import 'package:flutter/material.dart';

import '../helpers/profanity_filter.dart';
import '../helpers/translate_helper.dart';

class UsernameTextField extends StatelessWidget {
  final Key formKey;
  final Function(String?) onSaved;
  // Using a function because duplicate wouldn't be updated.
  final bool Function()? duplicate;

  const UsernameTextField({
    required this.formKey,
    required this.onSaved,
    this.duplicate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SizedBox(
        height: 110,
        child: TextFormField(
          onSaved: onSaved,
          decoration: InputDecoration(
            labelText: translate('username'),
            hintStyle: const TextStyle(fontSize: 12),
            hintText: translate('newUsername'),
            errorMaxLines: 2,
          ),
          maxLength: 12,
          maxLines: 1,
          validator: (value) {
            if (value == null || value.length <= 3) {
              return translate('usernameMoreThanFour');
            }
            if (duplicate != null && duplicate!()) {
              return translate('usernameTaken');
            }
            if (hasProfanity(value)) {
              return translate('badWord');
            }
            return null;
          },
        ),
      ),
    );
  }
}
