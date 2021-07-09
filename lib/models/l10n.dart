import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const l10nLanguages = [
  Locale('en', ''),
  Locale('ja', ''),
];

String translate(String key, BuildContext context) {
  if (key == 'Tic Tac\nAdvanced') return key;

  switch (key) {
    case 'singlePlayer':
      return AppLocalizations.of(context)!.singlePlayer;
    case 'multiplayer':
      return AppLocalizations.of(context)!.multiplayer;
    case 'settings':
      return AppLocalizations.of(context)!.settings;
    case 'random':
      return AppLocalizations.of(context)!.random;
    case 'easy':
      return AppLocalizations.of(context)!.easy;
    case 'normal':
      return AppLocalizations.of(context)!.normal;
    case 'hard':
      return AppLocalizations.of(context)!.hard;
    case 'localPlay':
      return AppLocalizations.of(context)!.localPlay;
    case 'onlinePlay':
      return AppLocalizations.of(context)!.onlinePlay;
    case 'wins':
      return AppLocalizations.of(context)!.wins;
    default:
      return '!!$key';
  }
}
