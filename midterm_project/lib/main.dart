import 'package:flutter/material.dart';
import 'package:midterm_project/profile_screen.dart';
import 'package:midterm_project/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:midterm_project/auth.dart';
import 'package:midterm_project/home_screen.dart';
import 'package:midterm_project/firebase_options.dart';
import 'package:midterm_project/launch_screen_options.dart';
import 'package:midterm_project/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => StreamProvider.value(
              initialData: null,
              value: AuthService().user,
              child: LaunchScreenOptions(),
            ),
        '/auth': (context) => StreamProvider.value(
              initialData: null,
              value: AuthService().user,
              child: AuthScreen(),
            ),
        '/home': (context) => StreamProvider.value(
              initialData: null,
              value: AuthService().user,
              child: HomeScreen(),
            ),
        '/profile': (context) => StreamProvider.value(
              initialData: null,
              value: AuthService().user,
              child: ProfileScreen(),
            ),
        '/search': (content) => StreamProvider.value(
              initialData: null,
              value: AuthService().user,
              child: SearchScreen(),
            ),
      },
    );
  }
}
