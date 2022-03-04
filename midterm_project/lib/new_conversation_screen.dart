import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';
import 'package:bubble/bubble.dart';

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen(
      {required this.uid, required this.contact, required this.convoID});
  final String? uid;
  final String convoID;
  final Map<String, dynamic> contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: true,
            title: Text(contact["firstName"] + " " + contact["lastName"])),
        body: ChatScreen(uid: uid!, convoID: convoID, contact: contact));
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {required this.uid, required this.convoID, required this.contact});
  final String uid, convoID;
  final Map<String, dynamic> contact;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String uid, convoID;
  late Map<String, dynamic> contact;
  TextEditingController _message = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    convoID = widget.convoID;
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        autofocus: true,
                        maxLines: 5,
                        controller: _message,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.send, size: 25),
                  onPressed: () async =>
                      onSendMessage(convoID, uid, contact["userId"]),
                ),
              ),
            ],
          ),
        ),
        width: double.infinity,
        height: 100.0);
  }

  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: firebaseFirestore
            .collection('messages')
            .doc(convoID)
            .collection(convoID)
            .orderBy('timeStamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) {
                return buildItem(index, snapshot.data!.docs[index]);
              },
              itemCount: snapshot.data?.docs.length,
              reverse: true,
              // controller: listScrollController,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    // if (!document['read'] && document['idTo'] == uid) {
    //   Database.updateMessageRead(document, convoID);
    // }
    if (document['content'] != "dummyData") {
      if (document['idFrom'] == uid) {
        // Right (my message)
        return Row(
          children: <Widget>[
            // Text
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Bubble(
                    color: Colors.black,
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.rightTop,
                    child: Text(document['content'],
                        style: TextStyle(color: Colors.white))),
                width: 200)
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Container(
                  child: Bubble(
                      color: Colors.grey,
                      elevation: 0,
                      padding: const BubbleEdges.all(10.0),
                      nip: BubbleNip.leftTop,
                      child: Text(document['content'],
                          style: TextStyle(color: Colors.black))),
                  width: 200.0,
                  margin: const EdgeInsets.only(left: 10.0),
                )
              ])
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    } else {
      return Row();
    }
  }

  void onSendMessage(String convoId, String idFrom, String idTo) async {
    await _auth.sendMessage(convoId, idFrom, idTo, _message.value.text);
    _message.clear();
  }
}



  

//   static void sendMessage(
//     String convoID,
//     String id,
//     String pid,
//     String content,
//     String timestamp,
//   ) {
//     final DocumentReference convoDoc =
//         firebaseFirestore.collection('messages').document(convoID);

//     convoDoc.setData(<String, dynamic>{
//       'lastMessage': <String, dynamic>{
//         'idFrom': id,
//         'idTo': pid,
//         'timestamp': timestamp,
//         'content': content,
//         'read': false
//       },
//       'users': <String>[id, pid]
//     }).then((dynamic success) {
//       final DocumentReference messageDoc = firebaseFirestore
//           .collection('messages')
//           .document(convoID)
//           .collection(convoID)
//           .document(timestamp);

//       Firestore.instance.runTransaction((Transaction transaction) async {
//         await transaction.set(
//           messageDoc,
//           <String, dynamic>{
//             'idFrom': id,
//             'idTo': pid,
//             'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//             'content': content,
//             'read': false
//           },
//         );
//       });
//     });
//   }
// }
