import 'mark.dart';

// ignore: constant_identifier_names
enum Player { None, Player1, Player2 }
// ignore: constant_identifier_names
enum GameType { Local, Online, Random, Easy, Normal, Hard }

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

final Map<int, Mark> baseGameMarks = {
  0: Mark(-1, Player.None),
  1: Mark(-1, Player.None),
  2: Mark(-1, Player.None),
  3: Mark(-1, Player.None),
  4: Mark(-1, Player.None),
  5: Mark(-1, Player.None),
  6: Mark(-1, Player.None),
  7: Mark(-1, Player.None),
  8: Mark(-1, Player.None),
};

final Map<String, Mark> baseGameMarks2 = {
  '0': Mark(-1, Player.None),
  '1': Mark(-1, Player.None),
  '2': Mark(-1, Player.None),
  '3': Mark(-1, Player.None),
  '4': Mark(-1, Player.None),
  '5': Mark(-1, Player.None),
  '6': Mark(-1, Player.None),
  '7': Mark(-1, Player.None),
  '8': Mark(-1, Player.None),
};
