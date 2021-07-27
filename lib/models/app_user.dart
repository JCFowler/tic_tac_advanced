import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid;
  String username;
  List<AppUser> friends;

  AppUser(
    this.uid,
    this.username,
    this.friends,
  );

  static Map<String, dynamic> friendToJson(AppUser friend) {
    return {
      'uid': friend.uid,
      'username': friend.username,
    };
  }

  static AppUser? docToObject(
    DocumentSnapshot<Map<String, dynamic>>? doc, {
    returnFriends = false,
  }) {
    try {
      if (doc != null && doc.data() != null) {
        var data = doc.data()!;

        List<AppUser> frs = [];
        if (returnFriends) {
          if (data['friends'] != null) {
            for (var friend in data['friends']) {
              frs.add(AppUser(friend['uid'], friend['username'], []));
            }
          }
        }

        return AppUser(doc.id, data['username'], frs);
      }
    } catch (error) {
      print('Error in creating friends.. $error');
    }

    return null;
  }
}
