import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: RegisterForm(),
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

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _registerFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Form(
        key: _registerFormKey,
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 200.0,
              height: 100.0,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).primaryColor,
                highlightColor: Colors.yellow,
                child: Text(
                  'INVENTORY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add username';
                  }
                },
              ),
            ),
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
                  border: InputBorder.none,
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
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add password';
                  } else if (value.length < 6) {
                    return 'Password should be more than 6 characters';
                  }
                },
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
                    'Already have an account?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
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
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_registerFormKey.currentState.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            authService
                                .handleRegister(
                              email: _emailController.text,
                              password: _passwordController.text,
                              username: _usernameController.text,
                            )
                                .then((user) {
                              setState(() {
                                _loading = false;
                              });
                              user.sendEmailVerification().then((res) {
                                Scaffold.of(context)
                                    .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'We have sent you a verification email',
                                        ),
                                      ),
                                    )
                                    .closed
                                    .then((closed) {
                                  Navigator.pushReplacementNamed(
                                      context, "/verify");
                                });
                              });
                            }).catchError((error) {
                              setState(() {
                                _loading = false;
                              });
                              if (error.toString().contains("NOINTERNET")) {
                                Flushbar(
                                  title: "Hey There",
                                  message:
                                      "You don't seem to have an active internet connection",
                                  duration: Duration(seconds: 4),
                                )..show(context);
                              } else if (error.message
                                  .contains("ERROR_EMAIL_ALREADY_IN_USE")) {
                                Flushbar(
                                  title: "Hey There",
                                  message:
                                      "This email has already been registered to another account",
                                  duration: Duration(seconds: 4),
                                )..show(context);
                              } else if (error.message
                                  .contains("ERROR_WEAK_PASSWORD")) {
                                Flushbar(
                                  title: "Hey There",
                                  message:
                                      "Please use a stronger password. Preferably at least 6 characters",
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
      ),
    );
  }
}
