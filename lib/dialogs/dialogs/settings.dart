import 'package:flutter/material.dart';

import '../../helpers/timeout.dart';
import '../../helpers/translate_helper.dart';
import '../../models/l10n.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/fire_service.dart';
import '../../widgets/username_text_field.dart';
import '../base_dialog_components.dart';

showSettingsDialog(BuildContext context, UserProvider userProvider,
    LocaleProvider localeProvider) {
  final deviceSize = MediaQuery.of(context).size;
  final form = GlobalKey<FormState>();
  final FireService fireService = FireService();

  String? enteredText;
  bool duplicate = false;
  bool loading = false;
  bool updated = false;
  Locale currentLocale = Localizations.localeOf(context);

  bool closed = false; // This is used to check if dialog has been closed.

  return basicDialogComponent(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    child: SizedBox(
      height: deviceSize.height * 0.8,
      child: StatefulBuilder(
        builder: (builderContext, setState) {
          return Column(
            children: [
              dialogHeaderComponent(context, 'settings'),
              Divider(
                thickness: 1.5,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 5),
              Text(
                translate('onlineUsername'),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
              Text(
                userProvider.username,
                style: TextStyle(
                  fontSize: 22,
                  color: updated
                      ? Colors.green
                      : Theme.of(context).secondaryHeaderColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: UsernameTextField(
                      formKey: form,
                      onSaved: (value) => enteredText = value,
                      duplicate: () => duplicate,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: updated
                          ? Colors.green
                          : Theme.of(context).secondaryHeaderColor,
                      child: IconButton(
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : updated
                                ? const Icon(
                                    Icons.check,
                                    size: 25,
                                  )
                                : const Icon(
                                    Icons.drive_file_rename_outline_sharp,
                                    size: 25,
                                  ),
                        color: Colors.white,
                        onPressed: () async {
                          if (loading || updated) return;

                          duplicate = false;
                          if (form.currentState!.validate()) {
                            form.currentState!.save();
                            setState(() {
                              loading = true;
                            });
                            if (await fireService
                                .doesUsernameExist(enteredText!)) {
                              setState(() {
                                duplicate = true;
                                loading = false;
                              });
                              form.currentState!.validate();
                            } else {
                              userProvider
                                  .updateUsername(enteredText!)
                                  .then((_) {
                                FocusScope.of(builderContext).unfocus();
                                setState(() {
                                  updated = true;
                                  loading = false;
                                });
                                form.currentState!.reset();
                                setTimeout(() {
                                  if (!closed) {
                                    setState(() {
                                      updated = false;
                                    });
                                  }
                                }, 5000);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translate('language'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  ...l10nLanguages.map(
                    (locale) {
                      return currentLocale.languageCode == locale.languageCode
                          ? ElevatedButton(
                              child: Text(locale.countryCode!),
                              onPressed: () {
                                setState(() {
                                  currentLocale = locale;
                                });
                                localeProvider.setLocale(locale);
                              },
                            )
                          : OutlinedButton(
                              child: Text(locale.countryCode!),
                              onPressed: () {
                                setState(() {
                                  currentLocale = locale;
                                });
                                localeProvider.setLocale(locale);
                              });
                    },
                  ).toList(),
                ],
              ),
              const Divider(
                height: 30,
              ),
            ],
          );
        },
      ),
    ),
  ).then((value) => closed = true);
}
