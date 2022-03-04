import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

class AuthService {
  void initialization() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final FirebaseFirestore _firestoredb = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // final googleSignIn = GoogleSignIn();
  bool _success = false;
  String _failureReason = "None";

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<Iterable<Map<String, dynamic>>> searchUserByFirstName(
      String searchText) async {
    var data = await _firestoredb
        .collection('users')
        .where("firstName", isEqualTo: searchText)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data()));
    return data;
  }

  Future<int> getNumberOfContactsForCurrentUser() async {
    return _firestoredb
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection("contacts")
        .get()
        .then((value) => value.size);
  }

  Future<String> sendMessage(
      String convoId, String? idFrom, String? idTo, String content) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = _firestoredb.collection('messages');
      var doc = await collectionRef.doc(convoId).get();
      String timeStamp = DateTime.now().toString();

      if (doc.exists) {
        await _firestoredb
            .collection("messages")
            .doc(convoId)
            .collection(convoId)
            .doc(timeStamp)
            .set({
          "content": content,
          "idFrom": idFrom,
          "idTo": idTo,
          "timeStamp": timeStamp
        });
      } else {
        await _firestoredb
            .collection("messages")
            .doc(convoId)
            .set({"content": content});

        Map<String, String> receiver = {};

        await _firestoredb
            .collection('users')
            .where('userId', isEqualTo: idFrom)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            receiver["firstName"] = doc["firstName"];
            receiver["lastName"] = doc["lastName"];
          });
        });

        await _firestoredb
            .collection("users")
            .doc(idTo)
            .collection("contacts")
            .doc(idFrom)
            .set({
          "firstName": receiver["firstName"],
          "lastName": receiver["lastName"],
          "userId": idFrom,
        });

        Map<String, String> sender = {};

        await _firestoredb
            .collection('users')
            .where('userId', isEqualTo: idTo)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            sender["firstName"] = doc["firstName"];
            sender["lastName"] = doc["lastName"];
          });
        });

        await _firestoredb
            .collection("users")
            .doc(idFrom)
            .collection("contacts")
            .doc(idTo)
            .set({
          "firstName": sender["firstName"],
          "lastName": sender["lastName"],
          "userId": idTo,
        });
      }
      return "SUCCESS";
    } catch (e) {
      return "FAILED";
    }
  }

  Object getMessages() {
    return _firestoredb.collection('messages').snapshots();
  }

  void storeGoogleUserInCollection(UserCredential user) {
    String timestamp = DateTime.now().toString();

    if (user.additionalUserInfo?.isNewUser == true) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection("users").doc(timestamp);

      var uuid = Uuid();
      var v1 = uuid.v1();
      Map<String, String> todoList = {
        "firstName": user.additionalUserInfo?.profile?["given_name"],
        "lastName": user.additionalUserInfo?.profile?["family_name"],
        "role": "customer",
        "timestamp": timestamp,
        "userId": v1,
      };

      documentReference
          .set(todoList)
          .whenComplete(() => print("Data stored successfully"));
    }
    return;
  }

  Future signUp(BuildContext context, String firstName, String lastName,
      String email, String password) async {
    print("Sign Up!");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String timestamp = DateTime.now().toString();

      var uuid = Uuid();
      var v1 = uuid.v1();

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user?.uid ?? v1);

      Map<String, String> userObject = {
        "firstName": firstName,
        "lastName": lastName,
        "timestamp": timestamp,
        "userId": userCredential.user?.uid ?? v1,
      };

      documentReference
          .set(userObject)
          .whenComplete(() => print("Data stored successfully"));

      Navigator.of(context).pushReplacementNamed("/home");
      _success = true;
      _failureReason = "None";
      return {_success, _failureReason};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _success = false;
        _failureReason = 'The password provided is too weak.';
        return {_success, _failureReason};
      } else if (e.code == 'email-already-in-use') {
        _success = false;
        _failureReason = 'The account already exists for that email.';
        return {_success, _failureReason};
      } else {
        _success = false;
        _failureReason = e.message.toString();
        return {_success, _failureReason};
      }
    } catch (e) {
      _success = false;
      _failureReason = e.toString();
      return {_success, _failureReason};
    }
  }

  Future sigInWithEmail(
      BuildContext context, String email, String password) async {
    print("login");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacementNamed("/home");
      return {_success, _failureReason};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _success = false;
        _failureReason = 'No user found for that email.';
        return {_success, _failureReason};
      } else if (e.code == 'wrong-password') {
        _success = false;
        _failureReason = 'Wrong password provided for that user.';
        return {_success, _failureReason};
      } else {
        _success = false;
        _failureReason = e.message.toString();
        return {_success, _failureReason};
      }
    } catch (e) {
      _success = false;
      _failureReason = e.toString();
      return {_success, _failureReason};
    }
  }

  Future<String> signOut() async {
    try {
      await _auth.signOut();
      return "SUCCESS";
    } catch (e) {
      return "FAILED";
    }
  }
}
