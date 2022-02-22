import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assignment_2/auth.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String title = "";
  String _role = "";
  final AuthService _auth = AuthService();
  String userId = "";

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .where('userId', isEqualTo: _auth.getUser())
        .get()
        .then((value) => {
              setState(() {
                userId = value.docs[0].data()["userId"];
                _role = value.docs[0].data()["role"];
              }),
            });
  }

  void postMessage(BuildContext context) {
    String timestamp = DateTime.now().toString();
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("posts").doc(timestamp);

    var uuid = Uuid();
    var v1 = uuid.v1();

    Map<String, String> todoList = {
      "message": title,
      "timestamp": timestamp,
      "id": v1
    };

    documentReference
        .set(todoList)
        .whenComplete(() => Navigator.of(context).pop());
  }

  void deletePost(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("posts").doc(item);

    documentReference
        .delete()
        .whenComplete(() => print("deleted successfully"));
  }

  void _signOut(BuildContext context) async {
    const singOutText = SnackBar(
      content: Text('Signed out!'),
    );

    const errorSigningOutText = SnackBar(
      content: Text('We ran into some issue. Please try again!'),
    );

    try {
      ScaffoldMessenger.of(context).showSnackBar(singOutText);
      if (await _auth.googleSignIn.isSignedIn()) {
        _auth.signOutWithGoogle();
      }
      _auth.signOut();
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(errorSigningOutText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Messages"),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Do you want to log out ?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => _signOut(context),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(Icons.logout),
              )),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot<Object?>? documentSnapshot =
                      snapshot.data?.docs[index];
                  return Container(
                      key: Key(index.toString()),
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text((documentSnapshot != null)
                              ? (documentSnapshot["message"])
                              : ""),
                          trailing: _role == "admin"
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      deletePost((documentSnapshot != null)
                                          ? (documentSnapshot["timestamp"])
                                          : "");
                                    });
                                  },
                                )
                              : null,
                        ),
                      ));
                });
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: _role == "admin"
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        title: const Text("Add Message"),
                        content: Container(
                          width: 400,
                          height: 100,
                          child: Column(
                            children: [
                              TextField(
                                onChanged: (String value) {
                                  title = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                postMessage(context);
                              });
                            },
                            child: const Text("Post Message"),
                          ),
                        ],
                      );
                    });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
