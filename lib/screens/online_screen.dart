import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_dialog.dart';
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
                      stream: _fireService.openGamesStream(),
                      builder:
                          (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docs = streamSnapshot.data!.docs;
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (ctx, index) => ListTile(
                              title: Text(
                                docs[index]['player1'],
                              ),
                              subtitle: Text(docs[index].id),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  _fireService.joinGame(
                                    docs[index].id,
                                    userProvider.uid,
                                    userProvider.username,
                                  );
                                  _gameProvider.setGameDoc(docs[index].id);
                                  Navigator.of(context)
                                      .pushNamed(GameScreen.routeName);
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
                      _fireService.createHostGame(
                        userProvider.uid,
                        userProvider.username,
                      );
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
