import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: RegisterForm(),
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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _registerFormKey,
      child: ListView(
        children: <Widget>[
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
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please add password';
                } else if (value.length < 6) {
                  return 'Password should be more than 6';
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
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
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
                color: Colors.amber,
                child: Text(
                  'REGISTER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_registerFormKey.currentState.validate()) {
                    authService
                        .handleRegister(
                      email: _emailController.text,
                      password: _passwordController.text,
                      username: _usernameController.text,
                    )
                        .then((user) {
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
                          Navigator.pushReplacementNamed(context, "/verify");
                        });
                      });
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
