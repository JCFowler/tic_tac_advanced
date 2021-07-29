import 'package:cloud_firestore/cloud_firestore.dart';

bool userWasInvited(List<Invited> invites, String username) {
  for (var inv in invites) {
    if (inv.inviteeUsername == username) {
      return true;
    }
  }

  return false;
}

class Invited {
  String gameId;
  String inviteeUsername;
  DateTime created;

  Invited(this.gameId, this.inviteeUsername, this.created);

  static Map<String, dynamic> toJson(Invited invited) {
    return {
      'gameId': invited.gameId,
      'inviteeUsername': invited.inviteeUsername,
      'created': invited.created.toIso8601String(),
    };
  }

  static Invited toObject(Map<String, dynamic> map) {
    return Invited(
      map['gameId'],
      map['inviteeUsername'],
      DateTime.parse(
        map['created'],
      ),
    );
  }
}

class AppUser {
  String uid;
  String username;
  List<AppUser> friends;
  List<Invited> invited;
  Invited? createdGame;
  Invited? invitedGame;

  AppUser(
    this.uid,
    this.username,
    this.friends,
    this.invited, {
    this.createdGame,
    this.invitedGame,
  });

  static Map<String, dynamic> friendToJson(AppUser friend) {
    return {
      'uid': friend.uid,
      'username': friend.username,
    };
  }

  static List<Map<String, dynamic>> friendListToJson(List<AppUser> friends) {
    List<Map<String, dynamic>> list = [];

    for (var friend in friends) {
      list.add(friendToJson(friend));
    }

    return list;
  }

  static AppUser? docToObject(
    DocumentSnapshot<Map<String, dynamic>>? doc, {
    returnFriends = false,
  }) {
    try {
      if (doc != null && doc.data() != null) {
        var data = doc.data()!;

        List<AppUser> frs = [];
        List<Invited> invs = [];
        if (returnFriends) {
          if (data['invited'] != null) {
            for (var invite in data['invited']) {
              invs.add(Invited(
                invite['gameId'],
                invite['inviteeUsername'],
                DateTime.parse(invite['created']),
              ));
            }
          }
          if (data['friends'] != null) {
            for (var friend in data['friends']) {
              Invited? inv;
              if (invs.isNotEmpty) {
                var index = invs.indexWhere(
                  (i) => i.inviteeUsername == friend['username'],
                );
                if (index != -1) {
                  inv = invs[index];
                }
              }

              frs.add(AppUser(
                friend['uid'],
                friend['username'],
                [],
                [],
                invitedGame: inv,
              ));
            }
          }
        }

        AppUser user = AppUser(doc.id, data['username'], frs, invs);

        if (data['createdGame'] != null) {
          user.createdGame = Invited.toObject(data['createdGame']);
        }

        return user;
      }
    } catch (error) {
      print('Error in creating friends.. $error');
    }

    return null;
  }
}
