import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/app_user.dart';
import '../models/constants.dart';
import '../providers/user_provider.dart';
import '../providers/game_provider.dart';
import '../screens/game_screen.dart';
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
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: Dialog(
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

Future<dynamic> showChangeUsernameDialog(
  BuildContext context, {
  FireService? fireService,
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
                  Navigator.pop(context, enteredText);
                }
              }
            },
          );
        }),
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

showFriendsDialog(BuildContext context, FireService fireService, double height,
    UserProvider userProvider, GameProvider gameProvider) {
  return _basicDialog(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    child: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          Text(
            'Friends',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: height,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            child: _friendsList(fireService, userProvider, gameProvider),
          )
        ],
      ),
    ),
  );
}

Widget _friendsList(FireService fireService, UserProvider userProvider,
    GameProvider gameProvider) {
  final _form = GlobalKey<FormState>();

  String? enteredText;
  bool loading = false;
  bool noUserFound = false;
  bool found = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
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
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      found ? Colors.green : Theme.of(context).primaryColor,
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

                        var friend = await fireService.findUser(enteredText!);

                        if (friend == null) {
                          setState(() {
                            noUserFound = true;
                          });

                          _form.currentState!.validate();
                        } else {
                          await fireService.addFriend(
                              userProvider.user, friend);
                          setState(() {
                            found = true;
                          });
                          setTimeout(() {
                            setState(() {
                              found = false;
                            });
                          }, 2500);
                          _form.currentState!.reset();
                          FocusScope.of(context).unfocus();
                        }

                        setState(() {
                          loading = false;
                        });
                      }
                    },
                  ),
                ),
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
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Colors.blue,
                                  ),
                                ),
                                onPressed: () {
                                  showLoadingDialog(
                                    context,
                                    'Waiting for ${friends[index].username}...',
                                  ).then((result) {
                                    if (result == 'cancel') {
                                      fireService.deleteInvite(
                                        userProvider.user,
                                        friends[index].uid,
                                      );
                                    }
                                  });
                                  fireService
                                      .inviteFriendGame(
                                          userProvider.user, friends[index])
                                      .then(
                                    (gameId) {
                                      gameProvider.setGameDoc(gameId);
                                      fireService
                                          .gameMatchStream(gameId)
                                          .firstWhere((gameModel) =>
                                              gameModel != null &&
                                              gameModel.addedPlayer != null)
                                          .then(
                                        (gameModel) {
                                          gameProvider.setStartingPlayer(
                                            gameModel!.hostPlayerGoesFirst
                                                ? Player.Player1
                                                : Player.Player2,
                                          );
                                          Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .pushNamed(GameScreen.routeName);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'Invite',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Center(
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () async {
                                      await fireService.removeFriend(
                                        userProvider.user,
                                        friends[index],
                                      );
                                      setState(() {
                                        null;
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
                }),
          ),
        ],
      );
    },
  );
}
