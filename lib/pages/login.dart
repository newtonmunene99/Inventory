import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[LoginForm()],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                hasFloatingPlaceholder: true,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.email,
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please add email';
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.lock_open,
                  ),
                  border: OutlineInputBorder()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,
              child: FlatButton(
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.0,
              child: RaisedButton(
                color: Colors.amber,
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_loginFormKey.currentState.validate()) {
                    authService
                        .handleSignIn(
                            email: _emailController.text,
                            password: _passwordController.text)
                        .then((user) {
                      if (user.isEmailVerified) {
                        Navigator.pushReplacementNamed(context, "/home");
                      } else {
                        Navigator.pushNamed(context, "/verify");
                      }
                    }).catchError((error) {
                      if (error.toString().contains("NOINTERNET")) {
                        Flushbar(
                          title: "Hey There",
                          message:
                              "You don't seem to have an active internet connection",
                          duration: Duration(seconds: 4),
                        )..show(context);
                      } else if (error.toString().contains("NOTREGISTERED")) {
                        Flushbar(
                          title: "Hey There",
                          message:
                              "You don't seem to be registered as an Admin",
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
                  } else {
                    Flushbar(
                      message: "Please input valid data",
                      duration: Duration(seconds: 4),
                    )..show(context);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
