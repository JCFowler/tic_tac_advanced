import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/app_user.dart';
import '../models/l10n.dart';
import '../providers/game_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';
import '../services/fire_service.dart';
import 'timeout.dart';

Future<T?> _basicDialog<T extends Object?>(
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

Widget _bottomSubmitButton({
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

Widget _basicHeader(BuildContext context, String title) {
  return SizedBox(
    height: 32,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              translate(title, context),
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

Future<dynamic> showChangeUsernameDialog(
  BuildContext context, {
  FireService? fireService,
  UserProvider? userProvider,
}) async {
  final _form = GlobalKey<FormState>();

  String? enteredText;
  bool duplicate = false;
  bool loading = false;

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
                    'Change username',
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
          child: Form(
            key: _form,
            child: SizedBox(
              height: 80,
              child: TextFormField(
                  onSaved: (value) => enteredText = value,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    errorMaxLines: 2,
                  ),
                  maxLength: 12,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.length <= 3) {
                      return 'Username has to be 4 or more characters.';
                    }
                    if (duplicate) {
                      return 'Username is taken.';
                    }
                    return null;
                  }),
            ),
          ),
        ),
        StatefulBuilder(builder: (context, setState) {
          return _bottomSubmitButton(
            text: 'Finish',
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

Future<bool?> showAlertDialog(
  BuildContext context,
  String title, {
  String? content,
  bool barrierDismissible = true,
  bool singleButton = false,
  String yesBtnText = 'Yes',
  String noBtnText = 'No',
}) {
  return _basicDialog(
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
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
                    minimumSize: const Size(
                      double.infinity,
                      40,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    noBtnText,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (!singleButton) const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  minimumSize: const Size(
                    double.infinity,
                    40,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  yesBtnText,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}

Future<dynamic> showOnlineRematchDialog(
  BuildContext context,
  String title, {
  String? content,
  bool barrierDismissible = false,
  String yesBtn = 'Yes',
  String noBtn = 'No',
}) {
  return _basicDialog(
    context,
    barrierDismissible: barrierDismissible,
    child: Column(
      children: [
        Text('Online'),
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
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).accentColor,
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
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).accentColor,
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

showFriendsDialog(
  BuildContext context,
  FireService fireService,
  double height,
  UserProvider userProvider,
  GameProvider gameProvider, {
  bool showDelete = true,
}) {
  final _form = GlobalKey<FormState>();

  String? enteredText;
  bool loading = false;
  bool noUserFound = false;
  bool found = false;
  bool closed = false; // This is used to check if dialog has been closed.

  return _basicDialog(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    child: SizedBox(
      height: height,
      child: Column(
        children: [
          _basicHeader(context, 'Friends'),
          Divider(
            thickness: 1.5,
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Form(
                      key: _form,
                      child: SizedBox(
                        height: 100,
                        child: TextFormField(
                          onSaved: (value) => enteredText = value,
                          decoration: const InputDecoration(
                            hintText: 'Friend\'s username',
                            hintStyle: TextStyle(fontSize: 12),
                            labelText: 'Add new friend',
                            errorMaxLines: 2,
                          ),
                          maxLength: 12,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.length <= 3) {
                              return 'Username has to be at least 4 characters.';
                            } else if (noUserFound) {
                              return 'Couldn\'t find $value';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: StatefulBuilder(builder: (builderContext, setState) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundColor: found
                            ? Colors.green
                            : Theme.of(context).accentColor,
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
                              : found
                                  ? const Icon(
                                      Icons.check,
                                      size: 25,
                                    )
                                  : const Icon(
                                      Icons.search,
                                      size: 25,
                                    ),
                          color: Colors.white,
                          onPressed: () async {
                            if (loading) return;

                            setState(() {
                              noUserFound = false;
                            });

                            if (_form.currentState!.validate()) {
                              _form.currentState!.save();
                              setState(() {
                                loading = true;
                              });

                              var friend =
                                  await fireService.findUser(enteredText!);

                              if (friend == null) {
                                setState(() {
                                  noUserFound = true;
                                });

                                _form.currentState!.validate();
                              } else {
                                await fireService.addFriend(
                                    userProvider.user!, friend);
                                setState(() {
                                  found = true;
                                });
                                setTimeout(() {
                                  if (!closed) {
                                    setState(() {
                                      found = false;
                                    });
                                  }
                                }, 2500);
                                _form.currentState!.reset();
                                FocusScope.of(builderContext).unfocus();
                              }

                              setState(() {
                                loading = false;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder(
                  stream: userProvider.friendStream,
                  builder: (ctx, AsyncSnapshot<List<AppUser>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final friends = snapshot.data!;

                    if (friends.isEmpty) {
                      return const Center(
                        child: Text('No friends yet...'),
                      );
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (ctx, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 16, right: 4),
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                friends[index].username,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                friends[index].invitedGame == null
                                    ? OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        onPressed: () {
                                          gameProvider.hostInvitedGame(
                                            context,
                                            friends[index],
                                          );
                                        },
                                        child: const Text(
                                          'Invite',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () =>
                                            gameProvider.joinInvitedGame(
                                          context,
                                          friends[index].invitedGame!,
                                        ),
                                        child: const Text(
                                          'Join',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                if (showDelete)
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Center(
                                      child: IconButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          showAlertDialog(
                                            context,
                                            'Remove friend?',
                                            content:
                                                'Are you sure you want to remove ${friends[index].username}?',
                                          ).then((value) {
                                            if (value != null && value) {
                                              fireService.removeFriend(
                                                userProvider.user!,
                                                friends[index],
                                              );
                                            }
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )),
        ],
      ),
    ),
  ).then((value) => closed = true);
}

showSettingsDialog(BuildContext context, UserProvider userProvider,
    LocaleProvider localeProvider) {
  final _deviceSize = MediaQuery.of(context).size;
  final _form = GlobalKey<FormState>();
  final FireService fireService = FireService();

  String? enteredText;
  bool duplicate = false;
  bool loading = false;
  bool updated = false;
  Locale currentLocale = Localizations.localeOf(context);

  bool closed = false; // This is used to check if dialog has been closed.

  return _basicDialog(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    child: SizedBox(
      height: _deviceSize.height * 0.8,
      child: StatefulBuilder(
        builder: (builderContext, setState) {
          return Column(
            children: [
              _basicHeader(context, 'settings'),
              Divider(
                thickness: 1.5,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 5),
              const Text(
                'Online Username',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
              Text(
                userProvider.username,
                style: TextStyle(
                  fontSize: 22,
                  color: updated ? Colors.green : Theme.of(context).accentColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Form(
                      key: _form,
                      child: SizedBox(
                        height: 100,
                        child: TextFormField(
                          onSaved: (value) => enteredText = value,
                          decoration: const InputDecoration(
                            hintText: 'New username',
                            hintStyle: TextStyle(fontSize: 12),
                            labelText: 'Change Username',
                            errorMaxLines: 2,
                          ),
                          maxLength: 12,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.length <= 3) {
                              return 'Username has to be 4 or more characters.';
                            }
                            if (duplicate) {
                              return 'Username is taken.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: updated
                          ? Colors.green
                          : Theme.of(context).accentColor,
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
                          if (_form.currentState!.validate()) {
                            _form.currentState!.save();
                            setState(() {
                              loading = true;
                            });
                            if (await fireService
                                .doesUsernameExist(enteredText!)) {
                              setState(() {
                                duplicate = true;
                                loading = false;
                              });
                              _form.currentState!.validate();
                            } else {
                              userProvider
                                  .updateUsername(enteredText!)
                                  .then((_) {
                                FocusScope.of(builderContext).unfocus();
                                setState(() {
                                  updated = true;
                                  loading = false;
                                });
                                _form.currentState!.reset();
                                setTimeout(() {
                                  if (!closed) {
                                    print('Working? $updated');
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
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).accentColor,
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
