import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_dialog.dart';
import '../models/app_user.dart';
import '../models/game_model.dart';
import '../providers/game_provider.dart';
import '../providers/user_provider.dart';
import '../services/fire_service.dart';
import '../widgets/background_gradient.dart';
import '../widgets/game_app_bar.dart';

class OnlineScreen extends StatefulWidget {
  static const routeName = '/online';

  const OnlineScreen({Key? key}) : super(key: key);

  @override
  _OnlineScreenState createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen>
    with SingleTickerProviderStateMixin {
  final _fireService = FireService();

  late final AnimationController _animation = AnimationController(
    duration: const Duration(milliseconds: 3600),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
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
                  children: [
                    RotationTransition(
                      turns: _animation,
                      child: const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 60,
                      ),
                    ),
                    const Text(
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
                        gameProvider.joinGame(context, games[index]);
                      },
                      child: const Text('Play'),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _friendStream(BuildContext context, GameProvider gameProvider,
      UserProvider userProvider) {
    return StreamBuilder(
      stream: userProvider.invitedStream,
      builder: (ctx, AsyncSnapshot<List<Invited>> streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final invited = streamSnapshot.data!;
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: invited.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: _animation,
                      child: const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 60,
                      ),
                    ),
                    const Text(
                      'No games yet',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: invited.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(
                      invited[index].inviteeUsername,
                    ),
                    subtitle: Text(
                        DateFormat('h:mm a').format(invited[index].created)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        gameProvider.joinInvitedGame(context, invited[index]);
                      },
                      child: const Text('Play'),
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
                    label: 'Anyone',
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                    child: const Icon(Icons.people, color: Colors.white),
                    onTap: () => gameProvider.hostGame(context),
                  ),
                  SpeedDialChild(
                    label: 'Friend',
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

  Widget _allTab(BuildContext context, gameProvider, userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
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
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.black54,
        ),
      ),
      child: _friendStream(context, gameProvider, userProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _gameProvider = Provider.of<GameProvider>(context);
    final _userProvider = Provider.of<UserProvider>(context);
    final _deviceSize = MediaQuery.of(context).size;

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
          padding: const EdgeInsets.only(top: 65),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Divider(
                  indent: _deviceSize.width * 0.2,
                  endIndent: _deviceSize.width * 0.2,
                  color: Theme.of(context).accentColor,
                  thickness: 1.5,
                ),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        labelStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                        labelColor: Colors.purple.shade800,
                        indicator: BoxDecoration(
                          color: Theme.of(context).dialogBackgroundColor,
                          // border: Border.all(
                          //   // color: Colors.red,
                          //   width: 2,
                          // ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        unselectedLabelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          FittedBox(
                            child: SizedBox(
                              height: _deviceSize.height * 0.08,
                              child: const Tab(text: 'All games'),
                            ),
                          ),
                          FittedBox(
                            child: SizedBox(
                              height: _deviceSize.height * 0.08,
                              child: const Tab(text: 'Friend games'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _deviceSize.height * 0.65,
                        child: TabBarView(
                          children: [
                            _allTab(context, _gameProvider, _userProvider),
                            _friendTab(context, _gameProvider, _userProvider),
                          ],
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
                                'Friends',
                                true,
                                _deviceSize.height * 0.8,
                              ),
                              _bottomBtn(
                                context,
                                _gameProvider,
                                'Host Game',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
