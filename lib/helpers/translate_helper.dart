import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

String translate(String key, {dynamic args}) {
  final translations = AppLocalizations.of(navigatorKey.currentContext!)!;

  if (args != null) {
    switch (key) {
      case 'areYouSureToRemove':
        return translations.areYouSureToRemove(args);
      case 'invitedYou':
        return translations.invitedYou(args);
      case 'waitingFor':
        return translations.waitingFor(args);
      case 'couldntFind':
        return translations.couldntFind(args);
      default:
        return '!!$key $args';
    }
  }

  switch (key) {
    case 'singlePlayer':
      return translations.singlePlayer;
    case 'multiplayer':
      return translations.multiplayer;
    case 'settings':
      return translations.settings;
    case 'easy':
      return translations.easy;
    case 'normal':
      return translations.normal;
    case 'hard':
      return translations.hard;
    case 'localPlay':
      return translations.localPlay;
    case 'onlinePlay':
      return translations.onlinePlay;
    case 'wins':
      return translations.wins;
    case 'noGamesYet':
      return translations.noGamesYet;
    case 'friend':
      return translations.friend;
    case 'friends':
      return translations.friends;
    case 'hostGame':
      return translations.hostGame;
    case 'allGames':
      return translations.allGames;
    case 'anyone':
      return translations.anyone;
    case 'addNewFriend':
      return translations.addNewFriend;
    case 'invite':
      return translations.invite;
    case 'join':
      return translations.join;
    case 'removeFriend':
      return translations.removeFriend;
    case 'no':
      return translations.no;
    case 'yes':
      return translations.yes;
    case 'exitGame':
      return translations.exitGame;
    case 'areYouSureToQuit':
      return translations.areYouSureToQuit;
    case 'gameFinished':
      return translations.gameFinished;
    case 'playAgain':
      return translations.playAgain;
    case 'changeUsername':
      return translations.changeUsername;
    case 'newUsername':
      return translations.newUsername;
    case 'language':
      return translations.language;
    case 'onlineUsername':
      return translations.onlineUsername;
    case 'friendsUsername':
      return translations.friendsUsername;
    case 'decline':
      return translations.decline;
    case 'cancel':
      return translations.cancel;
    case 'gameInviteDeclined':
      return translations.gameInviteDeclined;
    case 'joiningGame':
      return translations.joiningGame;
    case 'won':
      return translations.won;
    case 'lost':
      return translations.lost;
    case 'rematch':
      return translations.rematch;
    case 'quit':
      return translations.quit;
    case 'hostNewGame':
      return translations.hostNewGame;
    case 'waitingForSecondPlayer':
      return translations.waitingForSecondPlayer;
    case 'play':
      return translations.play;
    case 'username':
      return translations.username;
    case 'usernameMoreThanFour':
      return translations.usernameMoreThanFour;
    case 'usernameTaken':
      return translations.usernameTaken;
    case 'finished':
      return translations.finished;
    case 'playerQuit':
      return translations.playerQuit;
    case 'noFriends':
      return translations.noFriends;
    case 'noOne':
      return translations.noOne;
    case 'gameTied':
      return translations.gameTied;
    case 'bluePlayerWon':
      return translations.bluePlayerWon;
    case 'redPlayerWon':
      return translations.redPlayerWon;
    case 'hostEndedGame':
      return translations.hostEndedGame;
    case 'newUpdate':
      return translations.newUpdate;
    case 'goDownload':
      return translations.goDownload;
    case 'download':
      return translations.download;
    case 'badWord':
      return translations.badWord;
    case 'restart':
      return translations.restart;
    case 'resign':
      return translations.resign;
    case 'howToPlay':
      return translations.howToPlay;
    case 'htpTitleOverview':
      return translations.htpTitleOverview;
    case 'htpOne':
      return translations.htpOne;
    case 'htpTitleMoves':
      return translations.htpTitleMoves;
    case 'howToMoveOne':
      return translations.howToMoveOne;
    case 'howToMoveTwo':
      return translations.howToMoveTwo;
    case 'htpTitleTips':
      return translations.htpTitleTips;
    case 'tipOne':
      return translations.tipOne;
    case 'tipTwo':
      return translations.tipTwo;

    default:
      return '!!$key';
  }
}
