import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';

class VerifyPage extends StatefulWidget {
  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Password"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              authService.logout().then((_) {
                Navigator.pushReplacementNamed(context, "/login");
              }).catchError((error) {
                if (error.toString().contains("NOINTERNET")) {
                  Flushbar(
                    title: "Hey There",
                    message:
                        "You don't seem to have an active internet connection",
                    duration: Duration(seconds: 4),
                  )..show(context);
                } else {
                  print(error);
                  Flushbar(
                    title: "Hey There",
                    message:
                        "There seems to be a problem. Please try again later.",
                    duration: Duration(seconds: 4),
                  )..show(context);
                }
              });
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.mail,
              size: 60.0,
              color: Colors.indigo[300],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Please Verify Your Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  "We have sent a verification link to your registered email. Verifying your email enables us to optimize security for both you and we as a company. If you've already verified your email and are still running into this message, please restart the app."),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RaisedButton(
                child: Text("Did not receive a verification email?"),
                onPressed: () async {
                  FirebaseUser user = await authService.auth.currentUser();
                  user.sendEmailVerification().then((_) {
                    Flushbar(
                      title: "Hey There",
                      message: "We have sent you a verification email",
                      duration: Duration(seconds: 5),
                    )..show(context);
                  });
                },
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Colors.indigo[50],
              Colors.indigo[100],
              Colors.indigo[200],
              Colors.indigo[100],
            ],
          ),
        ),
      ),
    );
  }
}
