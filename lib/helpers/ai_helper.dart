import 'dart:math';

import '../models/mark.dart';
import '../providers/game_provider.dart';
import 'timeout.dart';

extension AiHelper on GameProvider {
  // bool _checkIfAnyMovesAreLeft() {
  //   if (gameMarks.)
  // }

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

  _aiPlayMove(int numberToUse, int position) {
    setTimeout(() {
      changeSelectedNumber(numberToUse);
      setTimeout(() {
        addMark(position);
      }, 800);
    }, 300);
  }

  Map<String, int> _aiRandomMove() {
    final _random = Random();

    final usableNumbers = _getUsableNumbers(numbers(Player.Player2));
    var numberToUse = usableNumbers[_random.nextInt(usableNumbers.length)];

    final availablePos = _getAvailablePositions(gameMarks, numberToUse);
    final position = availablePos[_random.nextInt(availablePos.length)];

    return {'numberToUse': numberToUse, 'position': position};
  }

  Map<String, int> _aiBestMove(int depth) {
    print('Start Move ------------------------------------------');
    var bestScore = -10000;
    Map<String, int> bestMove = {'numberToUse': -1, 'position': -1};

    // Get All Numbers the player hasn't used yet.
    final usableNumbers = _getUsableNumbers(numbers(Player.Player2));

    for (var number in usableNumbers) {
      print('!!!!!!!!!Using Number: $number  !!!!!!!!!!!!');
      // Get All positions the select number can go to
      final availablePos = _getAvailablePositions(gameMarks, number);

      for (var position in availablePos) {
        print('Using Position: $position --- Number: $number');
        var updatedUsedNumbers = Map<int, bool>.from(numbers(Player.Player2));
        updatedUsedNumbers.update(number, (value) {
          if (number == 1) {
            return false;
          }
          return true;
        });
        // usedNumbers[Player.Player2]!.update(number, (value) => true);
        // var score = minimax(Map<int, Mark>.from(board), usedNumbers,
        //     (depth - 1), Player.Player1);
        final board = Map<int, Mark>.from(gameMarks);
        if (board[position] != null) {
          board.update(position, (value) => Mark(number, player));
        } else {
          board[position] = Mark(number, player);
        }

        final result = _checkIfGameOver(board);
        if (result != null) {
          print('Start - Game Won by $result');
          if (result > 0) {
            bestMove.update('numberToUse', (value) => number);
            bestMove.update('position', (value) => position);
            return bestMove;
          }
        }

        // print(_player2Numbers);
        // print(updatedUsedNumbers);

        var score = _minimax(
          board,
          {
            Player.Player1: Map<int, bool>.from(numbers(Player.Player1)),
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
      final availablePos = _getAvailablePositions(board, number);

      for (var position in availablePos) {
        var lastItem = board[position];

        // Set Number
        if (board[position] != null) {
          board.update(position, (value) => Mark(number, player));
        } else {
          board[position] = Mark(number, player);
        }
        usedNumbers[player]!.update(number, (value) => true);

        var score = _minimax(
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

  int _minimax(
    Map<int, Mark> gameBoard,
    Map<Player, Map<int, bool>> usedNumbers,
    int depth,
    Player player,
  ) {
    final board = Map<int, Mark>.from(gameBoard);
    final result = _checkIfGameOver(board);
    if (result != null) {
      print('Game Won by $result');
      if (depth > 0) {
        return result * depth;
      } else if (depth == 0) {
        if (result == 100) {
          return 101;
        } else {
          return -101;
        }
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
      if (value == false) {
        usableNumbers.add(key);
      }
    });

    print(usableNumbers);
    return usableNumbers;
  }

  List<int> _getAvailablePositions(Map<int, Mark> board, int numberToUse) {
    final List<int> availablePos = [];

    gameMarks.forEach((key, mark) {
      if (mark.player == Player.None || mark.number < numberToUse) {
        availablePos.add(key);
      }
    });

    return availablePos;
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
