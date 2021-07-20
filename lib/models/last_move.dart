import 'dart:convert';

class LastMove {
  String playerUid;
  int position;
  int number;

  LastMove(
    this.playerUid,
    this.position,
    this.number,
  );

  Map<String, dynamic> toJson() => {
        'playerUid': playerUid,
        'position': position,
        'number': number,
      };

  static LastMove? jsonToObject(String? jsonData) {
    if (jsonData != null) {
      final Map<String, dynamic> data = json.decode(jsonData);

      return LastMove(data['playerUid'], data['position'], data['number']);
    }
    return null;
  }
}
