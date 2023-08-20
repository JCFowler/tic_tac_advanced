import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../widgets/empty_list_placeholder.dart';

import '../../helpers/timeout.dart';
import '../../helpers/translate_helper.dart';
import '../../models/app_user.dart';
import '../../models/game_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/fire_service.dart';
import '../base_dialog_components.dart';
import 'alert.dart';

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

  Stream<List<AppUser>> fStream = userProvider.friendStream;
  Stream<List<GameModel>> pStream = gameProvider.privateGameStream!;

  var combinedStream = CombineLatestStream.list([fStream, pStream]);

  return basicDialogComponent(
    context,
    barrierDismissible: true,
    outSidePadding: const EdgeInsets.all(20),
    child: SizedBox(
      height: height,
      child: Column(
        children: [
          dialogHeaderComponent(context, 'friends'),
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
                          decoration: InputDecoration(
                            hintText: translate('friendsUsername'),
                            hintStyle: const TextStyle(fontSize: 12),
                            labelText: translate('addNewFriend'),
                            errorMaxLines: 2,
                          ),
                          maxLength: 12,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.length <= 3) {
                              return translate('usernameMoreThanFour');
                            } else if (noUserFound) {
                              return translate('couldntFind', args: value);
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
                  stream: combinedStream,
                  builder: (ctx, AsyncSnapshot<List<List<Object>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final friends = snapshot.data![0] as List<AppUser>;
                    final privateGames = snapshot.data![1] as List<GameModel>;

                    if (friends.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: EmptyListPlaceholder(translate('noFriends')),
                      );
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (ctx, index) {
                        var invitedGame =
                            containsFriend(privateGames, friends[index].uid);
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
                                invitedGame != null
                                    ? ElevatedButton(
                                        onPressed: () => gameProvider.joinGame(
                                            context, invitedGame),
                                        child: Text(
                                          translate('join'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        onPressed: () {
                                          gameProvider.hostGame(
                                            context,
                                            friend: friends[index],
                                          );
                                        },
                                        child: Text(
                                          translate('invite'),
                                          style: const TextStyle(
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
                                            translate('removeFriend'),
                                            content: translate(
                                                'areYouSureToRemove',
                                                args: friends[index].username),
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
