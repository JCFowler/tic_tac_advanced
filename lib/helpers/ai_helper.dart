import 'dart:math';

import '../models/constants.dart';
import '../models/mark.dart';
import '../providers/game_provider.dart';
import 'timeout.dart';

const Map<Player, int> _winValues = {
  Player.Player1: -1000,
  Player.Player2: 1000
};
const Map<Player, int> _startValues = {
  Player.Player1: 10000,
  Player.Player2: -10000
};

extension AiHelper on GameProvider {
  // bool _checkIfAnyMovesAreLeft() {
  //   if (gameMarks.)
  // }

  void moveAI() {
    if (player == Player.Player2) {
      Map<String, int> aiNextMove = {};
      switch (gameType) {
        case GameType.Random:
          aiNextMove = _aiRandomMove();
          break;
        case GameType.Easy:
          var isAiFirstMove = true;
          gameMarks.forEach((key, value) {
            if (value.player == Player.Player2) {
              isAiFirstMove = false;
            }
          });
          isAiFirstMove
              ? aiNextMove = _aiRandomMove()
              : aiNextMove = _aiBestMove(1);
          break;
        case GameType.Normal:
          var isAiFirstMove = true;
          gameMarks.forEach((key, value) {
            if (value.player == Player.Player2) {
              isAiFirstMove = false;
            }
          });
          isAiFirstMove
              ? aiNextMove = _aiRandomMove()
              : aiNextMove = _aiBestMove(2);
          break;
        case GameType.Hard:
          aiNextMove = _aiBestMove(3);
          break;
        default:
          return;
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
    final random = Random();

    final usableNumbers = _getUsableNumbers(numbers(Player.Player2));
    var numberToUse = usableNumbers[random.nextInt(usableNumbers.length)];

    final availablePos = _getAvailablePositions(gameMarks, numberToUse);
    final position = availablePos[random.nextInt(availablePos.length)];

    return {'numberToUse': numberToUse, 'position': position};
  }

  Map<String, int> _aiBestMove(int depth) {
    var bestScore = _startValues[Player.Player2]!;

    Map<String, int> bestMove = {'numberToUse': -1, 'position': -1};

    // Get All Numbers the players hasn't used yet.
    final p1UsableNumbers = _getUsableNumbers(numbers(Player.Player1));
    final p2UsableNumbers = _getUsableNumbers(numbers(Player.Player2));

    for (var number in p2UsableNumbers) {
      // Get All positions the select number can go to
      final availablePos = _getAvailablePositions(gameMarks, number);
      for (var position in availablePos) {
        // Make sure the AI moves no matter what.
        if (bestMove['numberToUse'] == -1) {
          bestMove.update('numberToUse', (value) => number);
          bestMove.update('position', (value) => position);
        }

        final updatedP2Numbers = [...p2UsableNumbers];
        updatedP2Numbers.removeWhere((element) => element == number);

        final board = Map<int, Mark>.from(gameMarks);
        board.update(position, (value) => Mark(number, Player.Player2));

        final result = _checkIfGameOver(board);
        if (result == Player.Player2) {
          bestMove.update('numberToUse', (value) => number);
          bestMove.update('position', (value) => position);
          return bestMove;
        }

        var score = _minimax(
          board,
          {
            Player.Player1: p1UsableNumbers,
            Player.Player2: updatedP2Numbers,
          },
          depth,
          Player.Player1,
          _startValues[Player.Player2]!,
          _startValues[Player.Player1]!,
        );

        if (score > bestScore) {
          bestScore = score;
          bestMove.update('numberToUse', (value) => number);
          bestMove.update('position', (value) => position);
        }
      }
    }
    return bestMove;
  }

  int _minimax(
    Map<int, Mark> gameBoard,
    Map<Player, List<int>> usedNumbers,
    int depth,
    Player player,
    int alpha,
    int beta,
  ) {
    final board = Map<int, Mark>.from(gameBoard);

    final result = _checkIfGameOver(board);
    if (result != null) return _winValues[result]!;

    if (depth == 0) return _getBoardPoints(board, player, usedNumbers);

    return _findMove(board, usedNumbers, depth, player, alpha, beta);
  }

  int _findMove(
    Map<int, Mark> board,
    Map<Player, List<int>> playerNumbers,
    int depth,
    Player player,
    int alpha,
    int beta,
  ) {
    var bestScore = _startValues[player]!;

    for (var number in playerNumbers[player]!) {
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

        final usableNumbers = [...playerNumbers[player]!];

        if (number != 1) {
          usableNumbers.removeWhere((element) => element == number);
        }

        var score = _minimax(
          Map<int, Mark>.from(board),
          {
            Player.Player1: player == Player.Player1
                ? usableNumbers
                : playerNumbers[Player.Player1]!,
            Player.Player2: player == Player.Player2
                ? usableNumbers
                : playerNumbers[Player.Player2]!,
          },
          (depth - 1),
          player == Player.Player1 ? Player.Player2 : Player.Player1,
          alpha,
          beta,
        );

        // Revert Number
        board[position] = lastItem!;

        if (player == Player.Player1) {
          bestScore = min(score, bestScore);
          beta = min(beta, score);
        } else {
          bestScore = max(score, bestScore);
          alpha = max(alpha, score);
        }

        if (beta <= alpha) {
          break;
        }
      }
    }
    return bestScore;
  }

  List<int> _getUsableNumbers(Map<int, bool> playerNumbers) {
    final List<int> usableNumbers = [];
    playerNumbers.forEach((key, value) {
      if (value == false) {
        usableNumbers.add(key);
      }
    });

    return usableNumbers;
  }

  List<int> _getAvailablePositions(Map<int, Mark> board, int numberToUse) {
    final List<int> availablePos = [];

    gameMarks.forEach((key, mark) {
      if (mark.player == Player.None ||
          mark.number < numberToUse && key != lastMovePosition) {
        availablePos.add(key);
      }
    });

    return availablePos;
  }

  Player? _checkIfGameOver(Map<int, Mark> board) {
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;

      for (var index in line) {
        if (board[index]!.player != Player.None) {
          if (board[index]!.player == Player.Player1) {
            ++p1Count;
          } else if (board[index]!.player == Player.Player2) {
            ++p2Count;
          }

          if (p1Count > 0 && p2Count > 0) break;

          if (p1Count >= 3) return Player.Player1;
          if (p2Count >= 3) return Player.Player2;
        } else {
          break;
        }
      }
    }
    return null;
  }

  int _getBoardPoints(
      Map<int, Mark> board, Player player, Map<Player, List<int>> numbersLeft) {
    var totalScore = 0;
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;

      for (var index in line) {
        if (board[index]!.player == Player.Player1) {
          ++p1Count;
        } else if (board[index]!.player == Player.Player2) {
          ++p2Count;
        }
      }
      if (player == Player.Player1) {
        p1Count == 2 ? totalScore += p1Count * 2 : totalScore += p1Count;
        p2Count == 2 ? totalScore -= p2Count * 2 : totalScore -= p2Count;
        totalScore +=
            _getPointValueFromUsableNumbers(numbersLeft[Player.Player1]!) -
                _getPointValueFromUsableNumbers(numbersLeft[Player.Player2]!);
      }

      if (player == Player.Player2) {
        p1Count == 2 ? totalScore -= p1Count * 2 : totalScore -= p1Count;
        p2Count == 2 ? totalScore += p2Count * 2 : totalScore += p2Count;
        totalScore +=
            _getPointValueFromUsableNumbers(numbersLeft[Player.Player2]!) -
                _getPointValueFromUsableNumbers(numbersLeft[Player.Player1]!);
      }
    }
    return totalScore;
  }

  int _getPointValueFromUsableNumbers(List<int> playerNumbers) {
    var result = 0;

    for (var num in playerNumbers) {
      switch (num) {
        case 2:
          result += 1;
          break;
        case 3:
          result += 1;
          break;
        case 4:
          result += 2;
          break;
        case 5:
          result += 2;
          break;
        case 6:
          result += 3;
          break;
        case 7:
          result += 5;
          break;
        default:
          break;
      }
    }

    return result;
  }
}
