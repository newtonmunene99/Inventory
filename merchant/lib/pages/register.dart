import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../pages/set_password.dart';
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

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                  // border: OutlineInputBorder(),
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
                  onPressed: () async {
                    if (_registerFormKey.currentState.validate()) {
                      bool registered =
                          await authService.checkEmail(_emailController.text);
                      if (registered) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SetPasswordPage(email: _emailController.text),
                          ),
                        );
                      } else {
                        FlushbarHelper.createError(
                          title: "Hey there",
                          message:
                              "It seems you're not registered. Please contact Admin",
                          duration: Duration(seconds: 5),
                        )..show(context);
                      }
                    } else {
                      FlushbarHelper.createError(
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
