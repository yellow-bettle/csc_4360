import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class AuthService {
  void initialization() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success = false;
  String _failureReason = "None";

  String getUser() {
    return _auth.currentUser?.uid ?? "NOUSER";
  }

  Future signUp(BuildContext context, String firstName, String lastName,
      String email, String password) async {
    print("Sign Up!");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String timestamp = DateTime.now().toString();

      DocumentReference documentReference =
          FirebaseFirestore.instance.collection("users").doc(timestamp);

      var uuid = Uuid();
      var v1 = uuid.v1();

      Map<String, String> todoList = {
        "firstName": firstName,
        "lastName": lastName,
        "role": "customer",
        "timestamp": timestamp,
        "userId": userCredential.user?.uid ?? v1,
      };

      documentReference
          .set(todoList)
          .whenComplete(() => print("Data stored successfully"));

      Navigator.of(context).pushReplacementNamed("/welcome");
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
      Navigator.of(context).pushReplacementNamed('/welcome');
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

  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance

    final twitterLogin = new TwitterLogin(
        apiKey: dotenv.env["TWITTER_API_KEY"].toString(),
        apiSecretKey: dotenv.env["TWITTER_API_SECRET"].toString(),
        redirectURI: dotenv.env["TWITTER_REDIRECT_URI"].toString());

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(twitterAuthCredential);
  }

  void signOut() {
    _auth.signOut();
  }
}
