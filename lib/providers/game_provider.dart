import 'dart:math';

import 'package:flutter/material.dart';

import '../helpers/ai_helper.dart';
import '../helpers/custom_dialog.dart';
import '../helpers/timeout.dart';
import '../models/app_user.dart';
import '../models/constants.dart';
import '../models/game_model.dart';
import '../models/last_move.dart';
import '../models/mark.dart';
import '../screens/game_screen.dart';
import '../services/fire_service.dart';

class GameProvider with ChangeNotifier {
  String uid;
  String username;
  AppUser? user;

  GameProvider(this.uid, this.username);
  final _fireService = FireService();
  GameModel? _multiplayerData;

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
  var _gameType = GameType.Local;

  var _startingPlayer = Random().nextBool() ? Player.Player1 : Player.Player2;

  var _gameDoc = '';

  bool _gameTied = false;

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

  GameModel? get getMultiplayerData {
    return _multiplayerData;
  }

  void setGameType(GameType type) {
    _gameType = type;
  }

  void setGameDoc(String gameId) {
    _gameDoc = gameId;
  }

  void setPlayer(Player player) {
    _player = player;
  }

  void setStartingPlayer(Player player) {
    _startingPlayer = player;
  }

  void setMultiplayerData(GameModel data) {
    _multiplayerData = data;
    notifyListeners();
  }

  String getPlayerUsername(Player player) {
    if (_multiplayerData == null) return '';

    if (player == Player.Player1) {
      return username;
    } else {
      if (_multiplayerData!.hostPlayerUid == uid) {
        if (_multiplayerData!.addedPlayer != null) {
          return _multiplayerData!.addedPlayer!;
        } else {
          return 'No one..';
        }
      } else {
        return _multiplayerData!.hostPlayer;
      }
    }
  }

  void initalizeGame({
    required AnimationController numberController,
    required AnimationController lineController,
    required BuildContext buildContext,
  }) {
    _multiplayerData = null;
    _numberController = numberController;
    _lineController = lineController;
    _buildContext = buildContext;

    _player = _startingPlayer;
    _resetVariables();
    _scores.updateAll((key, value) => value = 0);

    if (gameType != GameType.Local && player == Player.Player2) {
      moveAI();
    }
  }

  void addOnlineMark(LastMove lastMove) {
    if (lastMove.playerUid != uid) {
      setTimeout(() {
        changeSelectedNumber(lastMove.number);
        setTimeout(() {
          _lastMovePosition = lastMove.position;
          _gameMarks[lastMove.position] = Mark(_selectedNumber, Player.Player2);

          final gameFinished = checkForWinningLine();

          if (!gameFinished) {
            changePlayer();
            _gameTied = checkForTieGame();
            // _runAnimation(_numberController);
          }
        }, 800);
      }, 300);
    }
  }

  void addMark(int position) {
    if (_gameTied) {
      _showDialog('Game Tied', yesText: 'Play again');
    }
    if (gameOver) {
      _showDialog(
        'Game finished!',
        content: getWinningContentString(),
        yesText: 'Play again',
      );
    }

    if (_selectedNumber != -1 && !gameOver) {
      if (_gameMarks[position]!.number < _selectedNumber) {
        _gameMarks[position] = Mark(_selectedNumber, _player);
        final gameFinished = checkForWinningLine();
        _lastMovePosition = position;

        final lastMove = LastMove(uid, position, _selectedNumber);

        if (gameType == GameType.Online) {
          _fireService.addMark(gameDoc, uid, username, gameMarks, lastMove);
        }

        if (!gameFinished) {
          changePlayer();
          _gameTied = checkForTieGame();
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
          setTimeout(() {
            _showDialog(
              'Game finished!',
              content: getWinningContentString(),
              yesText: 'Play again?',
            );
          }, 900);
          return true;
        }
      }
    }
    return false;
  }

  bool checkForTieGame() {
    var lowestNum = 10;
    for (var mark in _gameMarks.values) {
      if (mark.player == Player.None) {
        return false;
      }
      lowestNum = min(lowestNum, mark.number);
    }

    if (player == Player.Player1) {
      for (var i = lowestNum; i < _player1Numbers.length + 1; i++) {
        if (!_player1Numbers[i]!) {
          return false;
        }
      }
    } else {
      for (var i = lowestNum; i < _player2Numbers.length + 1; i++) {
        if (!_player1Numbers[i]!) {
          return false;
        }
      }
    }

    _showDialog('Game Tied', yesText: 'Play Again');
    return true;
  }

  String getWinningContentString() {
    if (player == Player.Player1) {
      return 'Blue player won!';
    } else {
      return 'Red player won!';
    }
  }

  void _showDialog(String title, {String? content, yesText = 'Yes'}) {
    if (_gameType == GameType.Online) {
      showOnlineRematchDialog(_buildContext!, title, content: content);
    } else {
      showAlertDialog(
        _buildContext!,
        title,
        content: content,
        singleButton: true,
        yesBtnText: yesText,
      ).then((value) {
        if (value != null && value) {
          gameResart();
        }
      });
    }
  }

  void gameResart({bool? hostPlayerGoesFirst}) {
    if (hostPlayerGoesFirst != null) {
      _player = hostPlayerGoesFirst ? Player.Player1 : Player.Player2;
    } else {
      _player =
          _startingPlayer == Player.Player1 ? Player.Player2 : Player.Player1;
    }
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
    _gameTied = false;
    _gameMarks.updateAll((key, value) => value = Mark(-1, Player.None));
    _lastMovePosition = -1;
    _startingPlayer = _player;
  }

  Future<void> _runAnimation(AnimationController? controller) async {
    if (controller != null) {
      controller.reset();
      return controller.forward();
    }
  }

  // Joining and Hosting game logic:

  joinGame(BuildContext context, GameModel game) {
    showLoadingDialog(context, 'Joining game...');
    _fireService
        .joinGame(
      game.id,
      uid,
      username,
    )
        .then((value) {
      setGameDoc(game.id);
      setStartingPlayer(
        game.hostPlayerGoesFirst ? Player.Player2 : Player.Player1,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(GameScreen.routeName);
    }).catchError((error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          'Host ended game.',
          textAlign: TextAlign.center,
        ),
      ));
    });
  }

  hostGame(BuildContext context) {
    showLoadingDialog(context, 'Waiting for second player...').then((result) {
      if (result == 'cancel') {
        _fireService.deleteGame(uid);
      }
    });
    _fireService.createHostGame(uid, username).then(
      (doc) {
        setGameDoc(doc.id);
        _fireService
            .gameMatchStream(doc.id)
            .firstWhere((gameModel) =>
                gameModel != null && gameModel.addedPlayer != null)
            .then(
          (gameModel) {
            setStartingPlayer(
              gameModel!.hostPlayerGoesFirst ? Player.Player1 : Player.Player2,
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(GameScreen.routeName);
          },
        );
      },
    );
  }

  hostInvitedGame(BuildContext context, AppUser friend) {
    showLoadingDialog(
      context,
      'Waiting for ${friend.username}...',
    ).then((result) {
      if (result == 'cancel') {
        _fireService.deleteInvite(
          user!,
          friend.uid,
        );
      }
    });
    _fireService.inviteFriendGame(user!, friend).then(
      (gameId) {
        setGameDoc(gameId);
        _fireService
            .gameMatchStream(gameId)
            .firstWhere((gameModel) =>
                gameModel != null && gameModel.addedPlayer != null)
            .then(
          (gameModel) {
            setStartingPlayer(
              gameModel!.hostPlayerGoesFirst ? Player.Player1 : Player.Player2,
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(GameScreen.routeName);
          },
        );
      },
    );
  }

  joinInvitedGame(BuildContext context, Invited invited) {
    showLoadingDialog(context, 'Joining ${invited.inviteeUsername}\'s game...');

    _fireService.joinInvitedGame(invited.gameId, uid, username).then((doc) {
      _fireService.removeInvitedGame(invited, uid);
      setGameDoc(invited.gameId);
      setStartingPlayer(
        doc.data()!['hostPlayerGoesFirst'] ? Player.Player2 : Player.Player1,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(GameScreen.routeName);
    }).catchError((error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          'Host ended game.',
          textAlign: TextAlign.center,
        ),
      ));
    });
  }
}
