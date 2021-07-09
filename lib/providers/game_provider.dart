import 'dart:math';

import 'package:flutter/material.dart';

import '../helpers/timeout.dart';
import '../models/mark.dart';

const Map<int, bool> baseNumbersMap = {
  1: false,
  2: false,
  3: false,
  4: false,
  5: false,
  6: false,
  7: false,
};

const winningLines = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6],
];

// ignore: constant_identifier_names
enum Player { Player1, Player2 }
// ignore: constant_identifier_names
enum AiType { None, Random, Easy, Normal, Hard }

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

  final Map<int, Mark> _gameMarks = {};
  List<int> _winningLine = [];
  var _lastMovePosition = -1;
  var _wentFirst = Player.Player1;
  var _AiGameType = AiType.None;

  int get selectedNumber {
    return _selectedNumber;
  }

  Player get player {
    return _player;
  }

  Map<Player, int> get scores {
    return _scores;
  }

  AiType get aiGameType {
    return _AiGameType;
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

  void setAiGameType(AiType type) {
    _AiGameType = type;
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

    if (aiGameType != AiType.None && player == Player.Player2) {
      moveAI();
    }
  }

  void addMark(int position) {
    if (_selectedNumber != -1 && !gameOver) {
      if (_gameMarks[position] == null ||
          _gameMarks[position]!.number < _selectedNumber) {
        _gameMarks[position] =
            Mark(_selectedNumber, _player, playerColor(_player));
        final gameFinished = checkForWinningLine();
        _lastMovePosition = position;
        if (!gameFinished) {
          changePlayer();
          _runAnimation(_numberController);
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

    if (aiGameType != AiType.None) {
      moveAI();
    }
  }

  void _addUsedNumber(int num) {
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
        if (_gameMarks[index] != null) {
          if (_gameMarks[index]!.player == Player.Player1) {
            ++p1Count;
          } else if (_gameMarks[index]!.player == Player.Player2) {
            ++p2Count;
          }
        }

        if (p1Count >= 3 || p2Count >= 3) {
          _winningLine = line;
          increaseScore(p1Count >= 3 ? Player.Player1 : Player.Player2);

          notifyListeners();
          _runAnimation(_lineController).then(
            (_) {
              if (_buildContext == null) return;

              showDialog(
                context: _buildContext!,
                builder: (ctx) => AlertDialog(
                  title: const Text('Game finished!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        gameResart();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Play again?'),
                    ),
                  ],
                ),
              );
            },
          );
          return true;
        }
      }
    }
    return false;
  }

  void gameResart() {
    _player = _wentFirst == Player.Player1 ? Player.Player2 : Player.Player1;
    _resetVariables();

    notifyListeners();

    if (aiGameType != AiType.None && player == Player.Player2) {
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
    _gameMarks.clear();
    _lastMovePosition = -1;
    _wentFirst = _player;
  }

  Future<void> _runAnimation(AnimationController? controller) async {
    if (controller != null) {
      controller.reset();
      return controller.forward();
    }
  }

  // Everything below is for AI
  void moveAI() {
    if (player == Player.Player2) {
      Map<String, int> aiNextMove = {};
      final usableNumbers = numbers(Player.Player2)
          .entries
          .where((element) => element.value == false)
          .toList();
      if (usableNumbers.length == 7) {
        aiNextMove = _aiRandomMove();
      } else {
        switch (aiGameType) {
          case AiType.Random:
            aiNextMove = _aiRandomMove();
            break;
          case AiType.Easy:
            aiNextMove = _aiBestMove(1);
            break;
          case AiType.Normal:
            break;
          case AiType.Hard:
            break;
          default:
            return;
        }
      }

      _aiPlayMove(aiNextMove['numberToUse']!, aiNextMove['position']!);
    }
  }

  Map<String, int> _aiRandomMove() {
    final usableNumbers = numbers(Player.Player2)
        .entries
        .where((element) => element.value == false)
        .toList();

    final _random = Random();

    var numberToUse = usableNumbers[_random.nextInt(usableNumbers.length)].key;

    var availableMoves = [0, 1, 2, 3, 4, 5, 6, 7, 8];

    _gameMarks.forEach((key, mark) {
      if (mark.player == Player.Player2) {
        availableMoves.removeWhere((element) => element == key);
      } else if (mark.number >= numberToUse) {
        availableMoves.removeWhere((element) => element == key);
      }
    });

    final position = availableMoves[_random.nextInt(availableMoves.length)];

    return {'numberToUse': numberToUse, 'position': position};
  }

  _aiPlayMove(int numberToUse, int position) {
    setTimeout(() {
      changeSelectedNumber(numberToUse);
      setTimeout(() {
        addMark(position);
      }, 800);
    }, 300);
  }

  Map<Player, int> winScores = {Player.Player1: -100, Player.Player2: 100};

  Map<String, int> _aiBestMove(int depth) {
    print('Start Move ------------------------------------------');
    var bestScore = -10000;
    Map<String, int> bestMove = {'numberToUse': -1, 'position': -1};

    // Get All Numbers the player hasn't used yet.
    final usableNumbers = _getUsableNumbers(_player2Numbers);

    for (var number in usableNumbers) {
      print('!!!!!!!!!Using Number: $number  !!!!!!!!!!!!');
      // Get All positions the select number can go to
      final availablePositions = _getAvailablePositions(_gameMarks, number);

      for (var position in availablePositions) {
        print('Using Position: $position --- Number: $number');
        var updatedUsedNumbers = Map<int, bool>.from(_player2Numbers);
        updatedUsedNumbers.update(number, (value) {
          if (number == 1) {
            return false;
          }
          return true;
        });
        // usedNumbers[Player.Player2]!.update(number, (value) => true);
        // var score = minimax(Map<int, Mark>.from(board), usedNumbers,
        //     (depth - 1), Player.Player1);
        final board = Map<int, Mark>.from(_gameMarks);
        if (board[position] != null) {
          board.update(
              position, (value) => Mark(number, player, playerColor(player)));
        } else {
          board[position] = Mark(number, player, playerColor(player));
        }

        // print(_player2Numbers);
        // print(updatedUsedNumbers);

        var score = minimax(
          board,
          {
            Player.Player1: Map<int, bool>.from(_player1Numbers),
            Player.Player2: updatedUsedNumbers,
          },
          depth,
          Player.Player1,
        );

        print('CURRENT SCORE: $score');

        print(
            'Score: $score, Bestscore: $bestScore, numberToUse: $number Position: $position');

        if (score > bestScore) {
          print('Updating Score: $score, BestScore: $bestScore');
          bestScore = score;
          bestMove.update('numberToUse', (value) => number);
          bestMove.update('position', (value) => position);
        }
        // print('AFTER: Score: $score, BestScore: $bestScore');
      }
      print('Bestscore: $bestScore, bestmove: $bestMove');
    }
    print('End Move ------------------------------------------');
    print('Sending: $bestMove, Score: $bestScore');
    return bestMove;
  }

  int _findMove(Map<int, Mark> board, Map<Player, Map<int, bool>> usedNumbers,
      int depth, Player player) {
    var bestScore = player == Player.Player2 ? -10000 : 10000;

    // Get All Numbers the player hasn't used yet.
    print('Getting usable numbers for $player, on Depth $depth');
    final usableNumbers = _getUsableNumbers(usedNumbers[player]!);

    for (var number in usableNumbers) {
      // Get All positions the select number can go to
      final availablePositions = _getAvailablePositions(board, number);

      for (var position in availablePositions) {
        var lastItem = board[position];

        // Set Number
        if (board[position] != null) {
          board.update(
              position, (value) => Mark(number, player, playerColor(player)));
        } else {
          board[position] = Mark(number, player, playerColor(player));
        }
        usedNumbers[player]!.update(number, (value) => true);

        var score = minimax(
          Map<int, Mark>.from(board),
          usedNumbers,
          (depth - 1),
          player == Player.Player1 ? Player.Player2 : Player.Player1,
        );

        // print('CURRENT SCORE: $score');

        // Revert Number
        if (lastItem != null) {
          board[position] = lastItem;
        } else {
          board.remove(position);
        }
        usedNumbers[player]!.update(number, (value) => false);

        if (player == Player.Player1) {
          if (score < bestScore) {
            bestScore = score;
          }
        } else {
          if (score > bestScore) {
            bestScore = score;
          }
        }
      }
    }
    return bestScore;
  }

  int minimax(Map<int, Mark> gameBoard, Map<Player, Map<int, bool>> usedNumbers,
      int depth, Player player) {
    final board = Map<int, Mark>.from(gameBoard);
    final result = _checkIfGameOver(board);
    if (result != null) {
      print('Game Won by $result');
      if (depth != 0 && depth != -1) {
        return result * depth;
      }
      return result;
    }
    if (depth < 0) {
      // print('Depth reached... Returning ${_getBoardPoints(board, player)}');
      return _getBoardPoints(board, player);
    }

    return _findMove(board, usedNumbers, depth, player);
  }

  List<int> _getUsableNumbers(Map<int, bool> playerNumbers) {
    final List<int> usableNumbers = [];
    playerNumbers.forEach((key, value) {
      // Because 1 can be used multiple times.
      if (value == false || key == 1) {
        usableNumbers.add(key);
      }
    });

    print(usableNumbers);
    return usableNumbers;
  }

  List<int> _getAvailablePositions(Map<int, Mark> board, int numberToUse) {
    var availablePositions = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    board.forEach((key, mark) {
      if (mark.number >= numberToUse) {
        availablePositions.removeWhere((element) => element == key);
      }
    });

    return availablePositions;
  }

  int? _checkIfGameOver(Map<int, Mark> board) {
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;

      for (var index in line) {
        if (board[index] != null) {
          if (board[index]!.player == Player.Player1) {
            ++p1Count;
          } else if (board[index]!.player == Player.Player2) {
            ++p2Count;
          }

          if (p1Count >= 3 || p2Count >= 3) {
            // // print(board);
            // // print('p1: $p1Count, p2: $p2Count, Line: $line');
          }

          if (p1Count >= 3) return -100;
          if (p2Count >= 3) return 100;
        }
      }
    }
    return null;
  }

  int _getBoardPoints(Map<int, Mark> board, Player player) {
    var totalScore = 0;
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;

      for (var index in line) {
        if (board[index] != null) {
          if (board[index]!.player == Player.Player1) {
            ++p1Count;
          } else if (board[index]!.player == Player.Player2) {
            ++p2Count;
          }

          if (player == Player.Player1) {
            p1Count == 2 ? totalScore += p1Count * 2 : totalScore += p1Count;
            p2Count == 2 ? totalScore -= p2Count * 2 : totalScore -= p2Count;
          }

          if (player == Player.Player2) {
            p1Count == 2 ? totalScore -= p1Count * 2 : totalScore -= p1Count;
            p2Count == 2 ? totalScore += p2Count * 2 : totalScore += p2Count;
          }
        }
      }
    }
    // print(totalScore);
    return totalScore;
  }
}
