import 'constants.dart';

class Mark {
  final int number;
  final Player player;

  Mark(
    this.number,
    this.player,
  );

  Map<String, dynamic> toJson() => {
        'number': number,
        'player': player.index,
      };

  @override
  String toString() {
    return 'number: $number, player: $player\n';
  }
}
