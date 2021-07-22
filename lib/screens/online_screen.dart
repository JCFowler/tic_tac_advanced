import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_dialog.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/fire_service.dart';
import '../widgets/app_button.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';
import 'game_screen.dart';

class OnlineScreen extends StatelessWidget {
  static const routeName = '/online';

  const OnlineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _gameProvider = Provider.of<GameProvider>(context);
    final _fireService = FireService();
    final _deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const GameAppBar(),
      extendBodyBehindAppBar: true,
      body: BackgroundGradient(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: _deviceSize.height * 0.12),
            child: Consumer<UserProvider>(
              builder: (ctx, userProvider, _) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            userProvider.username,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final newUsername = await showCustomDialog(context);
                          if (newUsername != null) {
                            userProvider.updateUsername(newUsername);
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.black54,
                      ),
                    ),
                    height: _deviceSize.height * 0.3,
                    child: StreamBuilder(
                      stream: _fireService.openGamesStream(userProvider.uid),
                      builder:
                          (ctx, AsyncSnapshot<List<GameModel>> streamSnapshot) {
                        if (streamSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final games = streamSnapshot.data!;
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: games.length,
                            itemBuilder: (ctx, index) => ListTile(
                              title: Text(
                                games[index].hostPlayer,
                              ),
                              subtitle: Text(games[index].id),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  showCustomLoadingDialog(context, "hi");
                                  _fireService
                                      .joinGame(
                                    games[index].id,
                                    userProvider.uid,
                                    userProvider.username,
                                  )
                                      .then((value) {
                                    _gameProvider.setGameDoc(games[index].id);
                                    _gameProvider.setStartingPlayer(
                                      games[index].hostPlayerGoesFirst
                                          ? Player.Player2
                                          : Player.Player1,
                                    );
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pushNamed(GameScreen.routeName);
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
                    ),
                  ),
                  AppButton(
                    'host game',
                    () {
                      showCustomLoadingDialog(context, "hi2").then((result) {
                        if (result == 'cancel') {
                          _fireService.deleteGame(userProvider.uid);
                        }
                      });
                      _fireService
                          .createHostGame(
                              userProvider.uid, userProvider.username)
                          .then((doc) {
                        _gameProvider.setGameDoc(doc.id);
                        _fireService
                            .gameMatchStream(doc.id)
                            .firstWhere((gameModel) =>
                                gameModel != null &&
                                gameModel.addedPlayer != null)
                            .then((gameModel) {
                          _gameProvider.setStartingPlayer(
                            gameModel!.hostPlayerGoesFirst
                                ? Player.Player1
                                : Player.Player2,
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(GameScreen.routeName);
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
