import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth.dart';
import 'package:flushbar/flushbar.dart';

class SetPasswordPage extends StatelessWidget {
  final String email;

  SetPasswordPage({Key key, @required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: SetPasswordForm(
          email: email,
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

class SetPasswordForm extends StatefulWidget {
  final String email;

  SetPasswordForm({@required this.email});

  @override
  _SetPasswordFormState createState() => _SetPasswordFormState();
}

class _SetPasswordFormState extends State<SetPasswordForm> {
  bool _loading = false;
  final _setPasswordFormKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Form(
        key: _setPasswordFormKey,
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 200.0,
              height: 100.0,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).primaryColor,
                highlightColor: Colors.yellow,
                child: Text(
                  'OFM',
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
                controller: _nameController,
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
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.lock,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add password';
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
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'COMPLETE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_setPasswordFormKey.currentState.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            authService
                                .handleRegister(
                                    email: widget.email,
                                    password: _passwordController.text,
                                    username: _nameController.text)
                                .then((user) {
                              user.sendEmailVerification().then((_) {
                                setState(() {
                                  _loading = false;
                                });
                                Flushbar(
                                  title: "Hey There",
                                  message:
                                      "We have sent you a verification email",
                                  duration: Duration(seconds: 5),
                                  onStatusChanged: (status) {
                                    if (status == FlushbarStatus.DISMISSED) {
                                      Navigator.pushReplacementNamed(
                                          context, "/verify");
                                    }
                                  },
                                )..show(context);
                              });
                            }).catchError((error) {
                              setState(() {
                                _loading = false;
                              });
                              print(error);
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
                                Flushbar(
                                  title: "Hey There",
                                  message:
                                      "There seems to be an error. Please try again later or contact Administrator.",
                                  duration: Duration(seconds: 4),
                                )..show(context);
                              }
                            });
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
