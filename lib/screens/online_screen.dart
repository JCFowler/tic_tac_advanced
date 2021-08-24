import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../dialogs/dialogs/change_username.dart';
import '../dialogs/dialogs/friend.dart';
import '../helpers/translate_helper.dart';
import '../models/game_model.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/fire_service.dart';
import '../widgets/app_title.dart';
import '../widgets/background_gradient.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/game_app_bar.dart';

class OnlineScreen extends StatefulWidget {
  static const routeName = '/online';

  const OnlineScreen({Key? key}) : super(key: key);

  @override
  _OnlineScreenState createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  final _fireService = FireService();
  late Stream<List<GameModel>> openGamesStream;

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    openGamesStream = _fireService.openGamesStream(userProvider.uid);
  }

  @override
  Widget build(BuildContext context) {
    final _gameProvider = Provider.of<GameProvider>(context, listen: false);
    final _userProvider = Provider.of<UserProvider>(context);
    final _deviceSize = MediaQuery.of(context).size;

    final topPadding = MediaQuery.of(context).padding.top +
        const GameAppBar().preferredSize.height -
        10;
    return Scaffold(
      appBar: GameAppBar(
        title: _userProvider.username,
        onTap: () async {
          await showChangeUsernameDialog(
            context,
            fireService: _fireService,
            userProvider: _userProvider,
          );
        },
      ),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            children: [
              Divider(
                indent: _deviceSize.width * 0.2,
                endIndent: _deviceSize.width * 0.2,
                color: Theme.of(context).accentColor,
                thickness: 1.5,
              ),
              AppTitle(
                translate('allGames'),
                regularSize: false,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  width: _deviceSize.width * 0.9,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.black54,
                    ),
                  ),
                  child: _gameStream(context, _gameProvider),
                ),
              ),
              SizedBox(
                height: _deviceSize.height * 0.1,
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomBtn(
                        context,
                        _gameProvider,
                        translate('friends'),
                        true,
                        _deviceSize.height * 0.8,
                      ),
                      _bottomBtn(
                        context,
                        _gameProvider,
                        translate('hostGame'),
                        false,
                        _deviceSize.height * 0.8,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameStream(BuildContext context, GameProvider gameProvider) {
    return StreamBuilder(
      stream: openGamesStream,
      builder: (ctx, AsyncSnapshot<List<GameModel>> streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final games = streamSnapshot.data!;
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: games.isEmpty
              ? EmptyListPlaceholder(translate('noGamesYet'))
              : ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(
                      games[index].hostPlayer,
                    ),
                    subtitle:
                        Text(DateFormat('h:mm a').format(games[index].created)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        gameProvider.joinGame(context, games[index]);
                      },
                      child: Text(translate('play')),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _bottomBtn(BuildContext context, GameProvider gameProvider,
      String text, bool isFriends, double height) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Consumer<UserProvider>(
        builder: (ctx, userProvider, _) => SpeedDial(
          label: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          overlayColor: Colors.black54,
          overlayOpacity: 0.4,
          childMargin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          onPress: isFriends
              ? () {
                  showFriendsDialog(context, _fireService, height, userProvider,
                      gameProvider);
                }
              : null,
          children: isFriends
              ? []
              : [
                  SpeedDialChild(
                    label: translate('anyone'),
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    child: const Icon(Icons.people, color: Colors.white),
                    onTap: () => gameProvider.hostGame(context),
                  ),
                  SpeedDialChild(
                    label: translate('friend'),
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    child: const Icon(Icons.person, color: Colors.white),
                    onTap: () {
                      showFriendsDialog(
                        context,
                        _fireService,
                        height,
                        userProvider,
                        gameProvider,
                        showDelete: false,
                      );
                    },
                  ),
                ],
        ),
      ),
    );
  }
}
