import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth.dart';
import '../providers/db.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    if (mounted) {
      authService.auth.onAuthStateChanged.listen((user) {
        if (user != null) {
          if (user.isEmailVerified) {
            dbService.getCurrentEmployee();
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            user.reload().then((_) async {
              user = await authService.auth.currentUser();
              if (user.isEmailVerified) {
                dbService.getCurrentEmployee();
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pushReplacementNamed(context, '/verify');
              }
            });
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: SizedBox(
            width: 200.0,
            height: 100.0,
            child: Shimmer.fromColors(
              baseColor: Colors.red,
              highlightColor: Colors.yellow,
              child: Text(
                'INVENTORY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
