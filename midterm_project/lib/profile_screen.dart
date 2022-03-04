import 'package:flutter/material.dart';
import 'package:midterm_project/auth.dart';

class ProfileScreen extends StatefulWidget {
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<int>(
        future: _auth.getNumberOfContactsForCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 60,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              snapshot.data.toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rank",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 38.0),
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
                          var res = await _auth.signOut();
                          if (res == 'SUCCESS') {
                            Navigator.pushReplacementNamed(context, '/');
                          } else {
                            print("Something went wrong. Please try again!");
                          }
                        },
                        child: const Text('Log out'),
                      ),
                    ],
                  )
                ],
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
