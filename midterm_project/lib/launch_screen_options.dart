import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LaunchScreenOptions extends StatelessWidget {
  const LaunchScreenOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      final ButtonStyle optionButtonStyle = ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.black,
        minimumSize: const Size(150, 20),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      );

      return Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        body: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 150, bottom: 10),
                child: const Text(
                  'Welcome to Chat App',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Image.network(
                  'https://as1.ftcdn.net/v2/jpg/03/67/00/34/1000_F_367003415_3JIx0TrEgjIGCC8PG2Ti0fTnbeOu8Pj1.jpg'),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: optionButtonStyle,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                    child: const Text('Get Started'),
                  )),
            ],
          ),
        ),
      );
    } else {
      return HomeScreen();
    }
  }
}
