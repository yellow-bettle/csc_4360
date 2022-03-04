import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen();

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success = true;
  String _failureReason = '';
  final AuthService _auth = AuthService();

  void _loginSignupNavigator(BuildContext context, String url) {
    Navigator.of(context).pushReplacementNamed(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 245, 247),
        body: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.only(top: 60),
          child: Form(
            key: _formKey, // NEW
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign In',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Container(
                  alignment: Alignment.center,
                  child: _success
                      ? Text("")
                      : Container(
                          margin: const EdgeInsets.all(7),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Text(
                            _success ? '' : _failureReason,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
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
                      HashSet<Object> response = await _auth.sigInWithEmail(
                          context,
                          _emailController.value.text,
                          _passwordController.value.text);

                      if (response.elementAt(0) == false) {
                        setState(() {
                          _success = false;
                          _failureReason = response.elementAt(1).toString();
                        });
                      }
                    }
                  },
                  // UPDATED
                  child: const Text('Sign In'),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 38.0),
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
                    if (_formKey.currentState!.validate()) {}
                  },
                  // UPDATED
                  child: const Text('Google Signin'),
                ),
                Padding(
                  padding: const EdgeInsets.all(50),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Don\'t have an account ?',
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
                Container(
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(50.0))),
                    child: Center(
                      child: Text(
                        "< Swipe left",
                        style: TextStyle(
                          color: Colors.white,
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
