import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './connection.dart';

final AuthProvider authService = AuthProvider();

class AuthProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Future<bool> checkEmail(String email) async {
    try {
      DocumentSnapshot employee =
          await _db.collection('users').document(email).get();
      return employee.exists;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<FirebaseUser> handleSignIn({String email, String password}) async {
    if (connectionService.connected.value) {
      bool emailexists = await checkEmail(email);

      if (emailexists) {
        try {
          return await auth.signInWithEmailAndPassword(
              email: email, password: password);
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

  Future<FirebaseUser> handleRegister(
      {String email, String password, String username}) async {
    if (connectionService.connected.value) {
      try {
        final FirebaseUser user = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

        UserUpdateInfo info = UserUpdateInfo();
        info.displayName = username;

        user.updateProfile(info);

        await _db.collection('users').document(email).setData({
          "uid": user.uid,
          "email": email,
          "username": username,
          "roles": {"admin": true, "editor": true},
          "active": true
        });

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
