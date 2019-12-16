import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './connection.dart';
import './db.dart';

final AuthProvider authService = AuthProvider();

class AuthProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Firestore _db;

  AuthProvider() {
    _db = dbService.firedb;
  }

  Future<FirebaseUser> handleSignIn({String email, String password}) async {
    if (connectionService.connected.value) {
      bool emailexists = await checkEmail(email);

      if (emailexists) {
        try {
          return (await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ))
              .user;
        } catch (e) {
          throw e;
        }
      } else {
        throw Exception("NOTREGISTERED");
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      DocumentSnapshot employee =
          await _db.collection('employees').document(email).get();
      return employee.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<FirebaseUser> handleRegister(
      {String email, String password, String username}) async {
    if (connectionService.connected.value) {
      try {
        final FirebaseUser user = (await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ))
            .user;

        UserUpdateInfo info = UserUpdateInfo();
        info.displayName = username;
        user.updateProfile(info);

        return user;
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> logout() async {
    if (connectionService.connected.value) {
      try {
        return await auth.signOut();
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }
}
