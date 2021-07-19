import 'dart:math';

import 'package:flutter/material.dart';

import '../helpers/ai_helper.dart';
import '../models/constants.dart';
import '../models/mark.dart';

class GameProvider with ChangeNotifier {
  AnimationController? _numberController;
  AnimationController? _lineController;
  BuildContext? _buildContext;

  int _selectedNumber = -1;
  Player _player = Player.Player1;
  final Map<Player, Color> _colors = {
    Player.Player1: Colors.blue,
    Player.Player2: Colors.red,
  };

  final Map<Player, int> _scores = {
    Player.Player1: 0,
    Player.Player2: 0,
  };

  final Map<int, bool> _player1Numbers = Map<int, bool>.from(baseNumbersMap);
  final Map<int, bool> _player2Numbers = Map<int, bool>.from(baseNumbersMap);

  final Map<int, Mark> _gameMarks = {...baseGameMarks};
  List<int> _winningLine = [];
  var _lastMovePosition = -1;
  var _wentFirst = Player.Player1;
  var _gameType = GameType.Local;

  var _gameDoc = '';

  int get selectedNumber {
    return _selectedNumber;
  }

  Player get player {
    return _player;
  }

  Map<Player, int> get scores {
    return _scores;
  }

  GameType get gameType {
    return _gameType;
  }

  String get gameDoc {
    return _gameDoc;
  }

  /// If no player is passed, will get current player.
  Color playerColor(Player player) {
    if (player == Player.Player1) {
      return _colors[Player.Player1] as Color;
    } else {
      return _colors[Player.Player2] as Color;
    }
  }

  Map<int, Mark> get gameMarks {
    return _gameMarks;
  }

  int get lastMovePosition {
    return _lastMovePosition;
  }

  List<int> get winningLine {
    return _winningLine;
  }

  bool get gameOver {
    return _winningLine.isNotEmpty;
  }

  void setGameType(GameType type) {
    _gameType = type;
  }

  void setGameDoc(String uid) {
    _gameDoc = uid;
  }

  void initalizeGame({
    required AnimationController numberController,
    required AnimationController lineController,
    required BuildContext buildContext,
  }) {
    _numberController = numberController;
    _lineController = lineController;
    _buildContext = buildContext;

    _player = Random().nextBool() ? Player.Player1 : Player.Player2;
    _resetVariables();
    _scores.updateAll((key, value) => value = 0);

    if (gameType != GameType.Local && player == Player.Player2) {
      moveAI();
    }
  }

  void addMark(int position) {
    if (_selectedNumber != -1 && !gameOver) {
      if (_gameMarks[position]!.number < _selectedNumber) {
        _gameMarks[position] = Mark(_selectedNumber, _player);
        final gameFinished = checkForWinningLine();
        _lastMovePosition = position;
        if (!gameFinished) {
          changePlayer();
          _runAnimation(_numberController).then(
            (value) => {
              if (player == Player.Player2 && gameType != GameType.Local)
                moveAI()
            },
          );
        }
      }
    }
  }

  Map<int, bool> numbers(Player player) {
    if (player == Player.Player1) {
      return _player1Numbers;
    } else {
      return _player2Numbers;
    }
  }

  void changePlayer() {
    _addUsedNumber(_selectedNumber);
    if (_player == Player.Player1) {
      _player = Player.Player2;
    } else {
      _player = Player.Player1;
    }
    _selectedNumber = -1;
    notifyListeners();
  }

  void _addUsedNumber(int num) {
    if (num == 1) return; // Can always use 1

    if (_player == Player.Player1) {
      _player1Numbers[num] = true;
    } else {
      _player2Numbers[num] = true;
    }
  }

  void changeSelectedNumber(int num) {
    if (_selectedNumber == num) {
      _selectedNumber = -1;
    } else {
      _selectedNumber = num;
    }
    notifyListeners();
  }

  void increaseScore(Player player) {
    _scores.update(player, (value) => value + 1);
    notifyListeners();
  }

  bool checkForWinningLine() {
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;

      for (var index in line) {
        if (_gameMarks[index]!.player == Player.Player1) {
          ++p1Count;
        } else if (_gameMarks[index]!.player == Player.Player2) {
          ++p2Count;
        }

        if (p1Count >= 3 || p2Count >= 3) {
          _winningLine = line;
          increaseScore(p1Count >= 3 ? Player.Player1 : Player.Player2);

          notifyListeners();
          _runAnimation(_lineController).then(
            (_) {
              if (_buildContext == null) return;

              _showDialog('Game finished!', 'Play again?');
            },
          );
          return true;
        }
      }
    }
    return false;
  }

  void _showDialog(String title, String body) {
    showDialog(
      context: _buildContext!,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              gameResart();
              Navigator.of(ctx).pop();
            },
            child: Text(body),
          ),
        ],
      ),
    );
  }

  void gameResart() {
    _player = _wentFirst == Player.Player1 ? Player.Player2 : Player.Player1;
    _resetVariables();

    notifyListeners();

    if (gameType != GameType.Local && player == Player.Player2) {
      moveAI();
    }
  }

  void _resetVariables() {
    _player1Numbers.forEach((key, value) {
      _player1Numbers[key] = false;
      _player2Numbers[key] = false;
    });
    _selectedNumber = -1;
    _winningLine = [];
    _gameMarks.updateAll((key, value) => value = Mark(-1, Player.None));
    _lastMovePosition = -1;
    _wentFirst = _player;
  }

  Future<void> _runAnimation(AnimationController? controller) async {
    if (controller != null) {
      controller.reset();
      return controller.forward();
    }
  }
}
