import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_dialog.dart';
import '../helpers/radiant_gradient_mask.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/fire_service.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';

class OnlineScreen extends StatelessWidget {
  static const routeName = '/online';

  OnlineScreen({Key? key}) : super(key: key);

  final _fireService = FireService();

  Widget _usernameHeader(BuildContext context, UserProvider userProvider) {
    return GestureDetector(
      onTapUp: (_) async {
        final newUsername = await showCustomDialog(
          context,
          fireService: _fireService,
        );
        if (newUsername != null) {
          userProvider.updateUsername(newUsername);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            clipBehavior: Clip.none,
            children: [
              Text(
                userProvider.username,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: -15,
                right: -15,
                child: RadiantGradientMask(
                  colors: const [
                    Color(0xfff5f7fa),
                    Color(0xffb8c6db),
                    Color(0xfff5f7fa),
                  ],
                  child: Icon(
                    Icons.settings,
                    size: 25,
                    color: Colors.blue[50],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameStream(BuildContext context, GameProvider gameProvider,
      UserProvider userProvider) {
    return StreamBuilder(
      stream: _fireService.openGamesStream(userProvider.uid),
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
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 60,
                    ),
                    Text(
                      'No games yet',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
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
                        showLoadingDialog(context, 'Joining game...');
                        _fireService
                            .joinGame(
                          games[index].id,
                          userProvider.uid,
                          userProvider.username,
                        )
                            .then((value) {
                          gameProvider.setGameDoc(games[index].id);
                          gameProvider.setStartingPlayer(
                            games[index].hostPlayerGoesFirst
                                ? Player.Player2
                                : Player.Player1,
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(GameScreen.routeName);
                        }).catchError((error) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            duration: Duration(seconds: 2),
                            content: Text(
                              'Host ended game.',
                              textAlign: TextAlign.center,
                            ),
                          ));
                        });
                      },
                      child: const Text('Play'),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _fab(BuildContext context, GameProvider gameProvider) {
    return Consumer<UserProvider>(
      builder: (ctx, userProvider, _) => SpeedDial(
        label: const Text(
          'Host game',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        overlayColor: Colors.black54,
        overlayOpacity: 0.4,
        childMargin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        children: [
          SpeedDialChild(
            label: 'Anyone',
            labelStyle: const TextStyle(
              fontSize: 20,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.people, color: Colors.white),
            onTap: () {
              showLoadingDialog(context, 'Waiting for second player...')
                  .then((result) {
                if (result == 'cancel') {
                  _fireService.deleteGame(userProvider.uid);
                }
              });
              _fireService
                  .createHostGame(userProvider.uid, userProvider.username)
                  .then(
                (doc) {
                  gameProvider.setGameDoc(doc.id);
                  _fireService
                      .gameMatchStream(doc.id)
                      .firstWhere((gameModel) =>
                          gameModel != null && gameModel.addedPlayer != null)
                      .then(
                    (gameModel) {
                      gameProvider.setStartingPlayer(
                        gameModel!.hostPlayerGoesFirst
                            ? Player.Player1
                            : Player.Player2,
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(GameScreen.routeName);
                    },
                  );
                },
              );
            },
          ),
          SpeedDialChild(
            label: 'Friend',
            labelStyle: const TextStyle(
              fontSize: 20,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, color: Colors.white),
            onTap: () {
              print('Go!');
              showFriendsDialog(context, true);
              // openDialogBoxShrink(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _allTab(BuildContext context, gameProvider, userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.black54,
        ),
      ),
      child: _gameStream(context, gameProvider, userProvider),
    );
  }

  Widget _friendTab(BuildContext context, gameProvider, userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.black54,
        ),
      ),
      child: _gameStream(context, gameProvider, userProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _gameProvider = Provider.of<GameProvider>(context);
    final _deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: Padding(
          padding: EdgeInsets.only(top: _deviceSize.height * 0.08),
          child: Consumer<UserProvider>(
            builder: (ctx, userProvider, _) => Column(
              children: [
                _usernameHeader(context, userProvider),
                const Divider(),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        labelStyle: const TextStyle(fontSize: 20),
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.black,
                        tabs: const [
                          FittedBox(child: Tab(text: 'All games')),
                          FittedBox(child: Tab(text: 'Friend games')),
                        ],
                      ),
                      Container(
                        height: _deviceSize.height * 0.65,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: TabBarView(
                          children: [
                            _allTab(context, _gameProvider, userProvider),
                            _friendTab(context, _gameProvider, userProvider),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _fab(context, _gameProvider),
    );
  }
}
