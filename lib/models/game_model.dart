import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants.dart';
import 'last_move.dart';
import 'mark.dart';

class GameModel {
  String id;
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
    this.id,
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
      'id': id,
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

  static GameModel? docToObject(DocumentSnapshot<Map<String, dynamic>>? doc) {
    if (doc != null && doc.data() != null) {
      return _convert(doc.data()!, doc.id);
    }

    return null;
  }

  static GameModel _convert(Map<String, dynamic> data, String gameId) {
    Map<int, Mark> gameMarksMap = {};
    final Map<String, dynamic> gameMarkData = json.decode(data['gameMarks']);

    gameMarkData.forEach((key, value) {
      gameMarksMap[int.parse(key)] =
          Mark(value['number'], Player.values[value['player']]);
    });

    var result = GameModel(
      gameId,
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
