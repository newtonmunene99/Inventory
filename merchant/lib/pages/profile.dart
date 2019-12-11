import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../providers/db.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  size: 50.0,
                ),
                title: Text(dbService.employee.value.name),
                subtitle: Text(dbService.employee.value.email),
                trailing: IconButton(
                  icon: Icon(Icons.exit_to_app),
                  tooltip: "Logout",
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
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
