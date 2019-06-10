import 'package:flutter/material.dart';

class VerifyPage extends StatefulWidget {
  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Please Verify Your Email',
          ),
        ),
      ),
    );
  }
}
