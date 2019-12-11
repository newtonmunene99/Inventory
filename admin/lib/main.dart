import 'package:flutter/material.dart';
import './pages/tabs.dart';
import './pages/login.dart';
import './pages/register.dart';
import './pages/splash.dart';
import './pages/verify.dart';
import './providers/db.dart';
import './providers/connection.dart';

void main() => runApp(Ofm());

class Ofm extends StatefulWidget {
  @override
  _OfmState createState() => _OfmState();
}

class _OfmState extends State<Ofm> {
  @override
  void initState() {
    connectionService.connected.listen((connected) {
      print(connected);
    });
    super.initState();
  }

  @override
  void dispose() {
    dbService.dispose();
    connectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (BuildContext context) => SplashScreen(),
        "/login": (BuildContext context) => LoginPage(),
        "/register": (BuildContext context) => RegisterPage(),
        "/verify": (BuildContext context) => VerifyPage(),
        "/home": (BuildContext context) => TabsPage(),
      },
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        accentColor: Colors.pinkAccent,
      ),
    );
  }
}
