import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../helpers/ai_helper.dart';
import '../helpers/custom_dialog.dart';
import '../helpers/snack_bar_helper.dart';
import '../helpers/timeout.dart';
import '../helpers/translate_helper.dart';
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
  MultiplayerNames? _multiplayerNames;

  late final AudioCache _audioCache = AudioCache(
    prefix: 'assets/audio/',
    fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
  )..loadAll(['move.wav', 'win.wav', 'win-long.wav']);

  AnimationController? _numberController;
  BuildContext? _buildContext;

  StreamSubscription<GameModel?>? _gameStream;

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
  var _gameType = GameType.None;

  var _startingPlayer = Random().nextBool() ? Player.Player1 : Player.Player2;

  var _gameDoc = '';

  bool _gameTied = false;

  Stream<List<GameModel>>? privateGameStream;

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

  GameModel? get multiplayerData {
    return _multiplayerData;
  }

  MultiplayerNames? get multiplayerNames {
    return _multiplayerNames;
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
    var newNames = MultiplayerNames.getNames(data);
    if (newNames != null) {
      _multiplayerNames = newNames;
    }
    _multiplayerData = data;

    notifyListeners();
  }

  var _waitingDiagOpen = false;

  void startGameStream() {
    if (gameDoc.isEmpty || _buildContext == null) return;

    _gameStream = _fireService.gameMatchStream(gameDoc).listen((gameModel) {
      if (gameModel != null) {
        setMultiplayerData(gameModel);
        if (gameModel.addedPlayer == null) {
          if (gameModel.hostRematch == false ||
              gameModel.addedRematch == false) {
          } else {
            _waitingDiagOpen = true;
            showLoadingDialog(
                    _buildContext!, translate('waitingForSecondPlayer'))
                .then((result) {
              if (result == 'cancel') {
                _waitingDiagOpen = false;
                leaveGame();
                Navigator.of(_buildContext!).pop();
              }
            });
            gameRestart(hostPlayerGoesFirst: gameModel.hostPlayerGoesFirst);
          }
        } else if (gameModel.hostRematch != null ||
            gameModel.addedRematch != null) {
          return;
        } else {
          if (_waitingDiagOpen) {
            _waitingDiagOpen = false;
            Navigator.pop(_buildContext!);
          }
          if (gameModel.lastMove != null) {
            addOnlineMark(gameModel.lastMove!);
          }
        }
      }
    });
  }

  startPrivateGameStream(String userId) {
    privateGameStream = _fireService.openPrivateGameStream(userId);
    _fireService.openPrivateGameStream(userId).listen((games) {
      if (games.isNotEmpty) {
        showInviteSnackBar(games[0], reset: true);
      } else {
        hideSnackBar();
      }
    });
  }

  declinePrivateGame(String gameId) {
    _fireService.declinePrivateGame(gameId);
  }

  void endGameStream() {
    if (_gameStream != null) _gameStream!.cancel();
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
          return translate('noOne');
        }
      } else {
        return _multiplayerData!.hostPlayer;
      }
    }
  }

  String getStaticUsername(Player player) {
    if (_multiplayerNames == null) return '';
    if (player == Player.Player1) {
      return username;
    } else {
      if (_multiplayerNames!.hostPlayerUid == uid) {
        return _multiplayerNames!.addedPlayer;
      } else {
        return _multiplayerNames!.hostPlayer;
      }
    }
  }

  bool isHostPlayer(Player player) {
    if (_multiplayerData == null) return false;

    return _multiplayerData!.hostPlayerUid == uid;
  }

  void initalizeGame({
    required AnimationController numberController,
    required BuildContext buildContext,
  }) {
    _multiplayerData = null;
    _numberController = numberController;
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
          _audioCache.play('move.wav');
          _lastMovePosition = lastMove.position;
          _gameMarks[lastMove.position] = Mark(_selectedNumber, Player.Player2);

          final gameFinished = checkForWinningLine();

          if (!gameFinished) {
            changePlayer();
            _gameTied = checkForTieGame();
            // _runAnimation(_numberController);
          }
        }, 600);
      }, 100);
    }
  }

  void addMark(int position) {
    if (_gameTied) {
      _showDialog(translate('gameTied'), yesText: translate('playAgain'));
    }
    if (gameOver) {
      _showDialog(
        translate('gameFinished'),
        content: getWinningContentString(),
        yesText: translate('playAgain'),
      );
    }

    if (_selectedNumber != -1 && !gameOver) {
      _audioCache.play('move.wav');
      if (_gameMarks[position]!.number < _selectedNumber) {
        _gameMarks[position] = Mark(_selectedNumber, _player);
        final gameFinished = checkForWinningLine();
        _lastMovePosition = position;

        final lastMove = LastMove(uid, position, _selectedNumber);

        if (gameDoc.isNotEmpty) {
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
          _audioCache.play('win-long.wav', mode: PlayerMode.LOW_LATENCY);
          setTimeout(() {
            _showDialog(
              translate('gameFinished'),
              content: getWinningContentString(),
              yesText: translate('playAgain'),
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

    _showDialog(translate('gameFinished'), yesText: translate('playAgain'));
    return true;
  }

  String getWinningContentString() {
    if (player == Player.Player1) {
      return translate('bluePlayerWon');
    } else {
      return translate('redPlayerWon');
    }
  }

  void _showDialog(String title, {String? content, yesText = 'Yes'}) {
    if (gameDoc.isNotEmpty) {
      showOnlineRematchDialog(
        _buildContext!,
        this,
        _multiplayerData!,
        stream: _fireService.gameMatchStream(gameDoc),
        won: player == Player.Player1,
      );
    } else {
      showAlertDialog(
        _buildContext!,
        title,
        content: content,
        singleButton: true,
        yesBtnText: yesText,
      ).then((value) {
        if (value != null && value) {
          gameRestart();
        }
      });
    }
  }

  void gameRestart({bool? hostPlayerGoesFirst}) {
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

  Future<void> updateRematch(answer) async {
    if (_multiplayerData != null) {
      await _fireService.rematch(
        _multiplayerData!.id,
        _multiplayerData!.hostPlayerUid == uid,
        answer,
      );
    }
  }

  Future<void> resetRematch() async {
    if (_multiplayerData != null) {
      return _fireService.resetRematch(_multiplayerData!.id);
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

  Future<void> restartOnlineGame({runFirebase = true}) async {
    if (runFirebase) {
      return _fireService.restartGame(
        gameDoc,
        !multiplayerData!.hostPlayerGoesFirst,
      );
    } else {
      _player =
          _startingPlayer == Player.Player1 ? Player.Player2 : Player.Player1;
      _resetVariables();
    }
  }

  Future<void> _runAnimation(AnimationController? controller) async {
    if (controller != null) {
      controller.reset();
      return controller.forward();
    }
  }

  // Joining and Hosting game logic:

  joinGame(BuildContext context, GameModel game) {
    showLoadingDialog(context, translate('joiningGame'));
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
      showSnackBar(translate('hostEndedGame'));
    });
  }

  hostGame(
    BuildContext context, {
    AppUser? friend,
    bool popGameScreen = false,
  }) {
    showLoadingDialog(
      context,
      friend != null
          ? translate('waitingFor', args: friend.username)
          : translate('waitingForSecondPlayer'),
    ).then((result) {
      if (result == 'cancel') {
        _fireService.deleteGame(uid);
      }
    });
    _fireService.hostGame(uid, username, friendUid: friend?.uid).then(
      (newGameId) {
        setGameDoc(newGameId);
        _fireService
            .gameMatchStream(newGameId)
            .firstWhere((gameModel) =>
                gameModel != null &&
                (gameModel.addedPlayer != null || gameModel.declined))
            .then(
          (gameModel) {
            if (gameModel!.declined) {
              showSnackBar(translate('gameInviteDeclined'),
                  textColor: Colors.red);
              Navigator.of(context).pop();
            } else {
              setStartingPlayer(
                gameModel.hostPlayerGoesFirst ? Player.Player1 : Player.Player2,
              );
              Navigator.of(context).pop();
              if (popGameScreen) Navigator.of(context).pop();
              Navigator.of(context).pushNamed(GameScreen.routeName);
            }
          },
        );
      },
    );
  }

  Future<void> leaveGame({
    bool autoOpen = true,
    bool popScreen = false,
  }) async {
    if (gameDoc.isNotEmpty) {
      endGameStream();
      gameRestart();
      if (multiplayerData == null || multiplayerData!.addedPlayer == null) {
        await _fireService.deleteGame(uid);
      } else {
        await _fireService.leaveGame(gameDoc, uid, autoOpen);
      }
      _gameDoc = '';
    }

    _gameType = GameType.None;

    if (popScreen) {
      Navigator.of(_buildContext!).pop();
    }
  }
}
