import 'package:flutter/material.dart';

import '../providers/game_provider.dart';

class Mark {
  final int number;
  final Player player;
  final Color color;

  Mark(
    this.number,
    this.player,
    this.color,
  );
}
