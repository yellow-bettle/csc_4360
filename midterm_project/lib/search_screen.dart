import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';
import 'package:provider/provider.dart';
import 'new_conversation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchText = TextEditingController();
  final AuthService _auth = AuthService();
  Iterable<Map<String, dynamic>> userFirstNames = [];

  void setData() async {
    Iterable<Map<String, dynamic>> data =
        await _auth.searchUserByFirstName(searchText.value.text);
    setState(() {
      userFirstNames = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        // The search area here
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              controller: searchText,
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: setData,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      searchText.clear();
                    },
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: userFirstNames.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                  leading: Icon(
                    Icons.person,
                    size: 30,
                  ),
                  trailing: Icon(Icons.chat),
                  title: Text(
                      '${userFirstNames.elementAt(index)["firstName"]} ${userFirstNames.elementAt(index)["lastName"]}'),
                  subtitle:
                      Text('${userFirstNames.elementAt(index)["location"]}'),
                  onTap: () async {
                    String convoId = getConversationID(
                        user?.uid, userFirstNames.elementAt(index)["userId"]);

                    await _auth.sendMessage(convoId, user?.uid,
                        userFirstNames.elementAt(index)["userId"], "dummyData");

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            NewConversationScreen(
                                uid: user?.uid,
                                contact: userFirstNames.elementAt(index),
                                convoID: convoId)));
                  }),
            );
          }),
    );
  }

  String getConversationID(String? userID, String peerID) {
    return userID.hashCode <= peerID.hashCode
        ? userID! + '_' + peerID
        : peerID + '_' + userID!;
  }
}
