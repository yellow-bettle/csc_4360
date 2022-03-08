import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen();

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  bool _success = true;
  String _failureReason = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 245, 247),
        body: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.only(top: 30),
          child: Form(
            key: _formKey, // NEW
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign up',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Expanded(
                    child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: _success
                      ? Text("")
                      : Container(
                          margin: const EdgeInsets.all(7),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Colors.black,
                          )),
                          child: Text(
                            _success ? '' : _failureReason,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                )),
                Expanded(
                  child: TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 27.0),
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.white;
                    }),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.black;
                    }),
                  ),
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      String response = await _auth.signUp(
                        context,
                        _firstName.value.text,
                        _lastName.value.text,
                        _emailController.value.text,
                        _passwordController.value.text,
                      );

                      if (response != "None") {
                        setState(() {
                          _success = false;
                          _failureReason = response;
                        });
                      }
                    }
                  },
                  // UPDATED
                  child: const Text('Sign up'),
                ),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Already have an account ? Swipe right =>',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ));
  }
}
