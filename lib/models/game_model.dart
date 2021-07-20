import 'dart:convert';

import 'constants.dart';
import 'last_move.dart';
import 'mark.dart';

class GameModel {
  String hostPlayer;
  String hostPlayerUid;
  String? addedPlayer;
  String? addedPlayerUid;
  Map<int, Mark> gameMarks;
  LastMove? lastMove;
  DateTime created;
  bool hostPlayerGoesFirst;
  bool open;

  GameModel(
    this.hostPlayer,
    this.hostPlayerUid,
    this.addedPlayer,
    this.addedPlayerUid,
    this.gameMarks,
    this.lastMove,
    this.created,
    this.hostPlayerGoesFirst,
    this.open,
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> gameMarksMap = {};
    gameMarks.forEach((key, value) {
      gameMarksMap['$key'] = value.toJson();
    });

    return {
      'hostPlayer': hostPlayer,
      'hostPlayerUid': hostPlayerUid,
      'addedPlayer': addedPlayer,
      'addedPlayerUid': addedPlayerUid,
      'gameMarks': gameMarksMap,
      'created': created.toIso8601String(),
      'hostPlayerGoesFirst': hostPlayerGoesFirst,
      'open': open,
    };
  }

  static GameModel jsonToObject(String jsonData) {
    final Map<String, dynamic> data = json.decode(jsonData);

    return _convert(data);
  }

  static GameModel? docToObject(Map<String, dynamic>? data) {
    if (data != null) {
      return _convert(data);
    }

    return null;
  }

  static GameModel _convert(Map<String, dynamic> data) {
    Map<int, Mark> gameMarksMap = {};
    final Map<String, dynamic> gameMarkData = json.decode(data['gameMarks']);

    gameMarkData.forEach((key, value) {
      gameMarksMap[int.parse(key)] =
          Mark(value['number'], Player.values[value['player']]);
    });

    var result = GameModel(
      data['hostPlayer'],
      data['hostPlayerUid'],
      data['addedPlayer'],
      data['addedPlayerUid'],
      gameMarksMap,
      LastMove.jsonToObject(data['lastMove']),
      DateTime.parse(data['created']),
      data['hostPlayerGoesFirst'],
      data['open'],
    );

    return result;
  }
}
