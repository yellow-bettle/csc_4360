import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';
import 'package:midterm_project/search_screen.dart';
import 'package:provider/provider.dart';
import 'new_conversation_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<User?>(context);

    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("contacts")
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text('Chat'),
        actions: [
          IconButton(
              onPressed: () => {Navigator.pushNamed(context, '/search')},
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: Icon(Icons.person))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                child: ListTile(
                    leading: Image.asset(
                      'assets/profile.png',
                      width: 40,
                      height: 40,
                    ),
                    trailing: Icon(Icons.chat),
                    title: Text(data['firstName'] + " " + data['lastName']),
                    subtitle: Row(children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                      ),
                      Text(
                        data["location"],
                        style: TextStyle(fontSize: 12),
                      )
                    ]),
                    onTap: () async {
                      String convoId =
                          getConversationID(user?.uid, data["userId"]);

                      await _auth.sendMessage(
                          convoId, user?.uid, data["userId"], "dummyData");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              NewConversationScreen(
                                  uid: user?.uid,
                                  contact: data,
                                  convoID: convoId)));
                    }),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String getConversationID(String? userID, String peerID) {
    return userID.hashCode <= peerID.hashCode
        ? userID! + '_' + peerID
        : peerID + '_' + userID!;
  }
}
