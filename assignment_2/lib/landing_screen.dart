import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assignment_2/auth.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen();
  final AuthService _auth = AuthService();
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: style,
                onPressed: () async {
                  UserCredential? user;
                  try {
                    UserCredential? user = await _auth.signInWithGoogle();
                    print(user);
                    _auth.storeGoogleUserInCollection(user);
                    if (user != null) {
                      Navigator.of(context).pushReplacementNamed("/welcome");
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('Twitter Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
