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
      // if (usableNumbers.length == 7) {
      //   aiNextMove = _aiRandomMove();
      // } else {
      switch (aiGameType) {
        case AiType.Random:
          aiNextMove = _aiRandomMove();
          break;
        case AiType.Easy:
          aiNextMove = _aiBestMove(2);
          break;
        case AiType.Normal:
          break;
        case AiType.Hard:
          break;
        default:
          return;
      }
      // }

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
    // return {'numberToUse': 1, 'position': 0};
  }

  Map<String, int> _aiBestMove(int depth) {
    // print('Start Move ------------------------------------------');
    var bestScore = -100000;
    Map<String, int> bestMove = {'numberToUse': -1, 'position': -1};

    // Get All Numbers the player hasn't used yet.
    final usableNumbers = _getUsableNumbers(numbers(Player.Player2));

    for (var number in usableNumbers) {
      // print('!!!!!!!!!Using Number: $number  !!!!!!!!!!!!');
      // Get All positions the select number can go to
      final availablePos = _getAvailablePositions(gameMarks, number);

      for (var position in availablePos) {
        // print('Using Position: $position --- Number: $number');
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
          // print('Start - Game Won by $result');
          if (result > 0) {
            bestMove.update('numberToUse', (value) => number);
            bestMove.update('position', (value) => position);
            return bestMove;
          }
        }

        var score = _minimax(
          board,
          {
            Player.Player1: Map<int, bool>.from(numbers(Player.Player1)),
            Player.Player2: updatedUsedNumbers,
          },
          depth,
          Player.Player1,
        );

        // print('score: $score, bestScore: $bestScore');
        // // print('score: $score, numberToUse: $number Position: $position');
        // // print('bestScore: $bestScore');

        if (score > bestScore) {
          // // print('Updating Score: $score, BestScore: $bestScore');
          bestScore = score;
          bestMove.update('numberToUse', (value) => number);
          bestMove.update('position', (value) => position);
        }
        // // print('AFTER: Score: $score, BestScore: $bestScore');
      }
    }
    // print('End Move ------------------------------------------');
    // print('Sending: $bestMove, BestScore: $bestScore');
    return bestMove;
  }

  int _findMove(Map<int, Mark> board, Map<Player, Map<int, bool>> usedNumbers,
      int depth, Player player) {
    var bestScore = player == Player.Player2 ? -100000 : 100000;

    // Get All Numbers the player hasn't used yet.
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

        // // print('Score: $score');

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
      if (depth > 0) {
        return result * depth;
      } else if (depth == 0) {
        if (result == 1000) {
          return 10001;
        } else {
          return -10001;
        }
      }
      return result;
    }
    if (depth < 0) {
      return _getBoardPoints(board, player, usedNumbers);
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

          if (p1Count >= 3) return -1000;
          if (p2Count >= 3) return 1000;
        }
      }
    }
    return null;
  }

  int _getBoardPoints(Map<int, Mark> board, Player player,
      Map<Player, Map<int, bool>> numbersLeft) {
    var totalScore = 0;
    for (var line in winningLines) {
      var p1Count = 0;
      var p2Count = 0;
      final p1Nums = _getUsableNumbers(numbersLeft[Player.Player1]!);
      final p2Nums = _getUsableNumbers(numbersLeft[Player.Player2]!);

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
            totalScore += _getPointValueFromUsableNumbers(
                    numbersLeft[Player.Player1]!) -
                _getPointValueFromUsableNumbers(numbersLeft[Player.Player2]!);
          }

          if (player == Player.Player2) {
            p1Count == 2 ? totalScore -= p1Count * 2 : totalScore -= p1Count;
            p2Count == 2 ? totalScore += p2Count * 2 : totalScore += p2Count;
            totalScore += _getPointValueFromUsableNumbers(
                    numbersLeft[Player.Player2]!) -
                _getPointValueFromUsableNumbers(numbersLeft[Player.Player1]!);
          }
        }
      }
    }
    // // print(totalScore);
    return totalScore;
  }

  int _getPointValueFromUsableNumbers(Map<int, bool> playerNumbers) {
    var result = 0;
    final playerNums = _getUsableNumbers(playerNumbers);

    for (var num in playerNums) {
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
