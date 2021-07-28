import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class TestScreen extends StatelessWidget {
  TestScreen({Key? key}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              var result = await _auth.signInAnonymously();
              if (result == null) {
                print('couldnt sign in');
              } else {
                print('Signed in!');
                print(result);
              }
            },
            child: Text('SignIn'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
            },
            child: Text('Sign out'),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('testing').snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final docs = streamSnapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) => Container(
                    child: Text(docs[index]['test']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          FirebaseFirestore.instance.collection('testing').add(
            {'test': 'Added by app'},
          );
        },
      ),
    );
  }
}
