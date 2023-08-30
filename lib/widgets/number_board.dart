import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../providers/game_provider.dart';
import 'board_number.dart';

class NumberBoard extends StatelessWidget {
  final Player player;
  final String username;

  const NumberBoard(
    this.player,
    this.username, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUserNameTemplate(context),
        Consumer<GameProvider>(
          builder: (ctx, game, _) => Row(
            children: _buildNumberList(
              game.numbers(player),
              context,
              game,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameTemplate(BuildContext context) {
    if (username == '') return const SizedBox.shrink();

    final usernameTextWidget = Text(
      username,
      style: const TextStyle(
        fontSize: 24,
      ),
    );

    return Container(
      alignment: Alignment.center,
      child: player == Player.Player1
          ? usernameTextWidget
          : RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: usernameTextWidget,
            ),
    );
  }

  List<Widget> _buildNumberList(
      Map<int, bool> numbers, BuildContext context, GameProvider game) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> list = [];
    numbers.forEach((key, value) {
      list.add(
        game.canSelectNumber(player, key == 1 ? false : value)
            ? Draggable(
                data: key,
                maxSimultaneousDrags: 1,
                onDragStarted: () => game.changeSelectedNumber(key),
                onDraggableCanceled: (_, __) => game.changeSelectedNumber(-1),
                onDragCompleted: () => game.changeSelectedNumber(-1),
                ignoringFeedbackSemantics: false,
                feedback: player == Player.Player1
                    ? _numberWidget(key, value, width)
                    : RotationTransition(
                        turns: const AlwaysStoppedAnimation(180 / 360),
                        child: _numberWidget(key, value, width)),
                childWhenDragging: _numberWidget(key, value, width),
                child: _numberWidget(key, value, width),
              )
            : _numberWidget(key, value, width),
      );
    });
    return list;
  }

  Widget _numberWidget(int key, bool value, double width) {
    return BoardNumber(
      number: key,
      player: player,
      used: key == 1 ? false : value,
      width: width / 7,
    );
  }
}
