import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:rxdart/subjects.dart';

Connection connectionService = Connection();

class Connection {
  StreamSubscription<ConnectivityResult> _subscription;
  final connected = BehaviorSubject<bool>();

  Connection() {
    hasInternet();
  }

  void hasInternet() {
    try {
      _subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) async {
        if (result != ConnectivityResult.none) {
          connected.add(await DataConnectionChecker().hasConnection);
        } else {
          connected.add(false);
        }
      });
    } catch (e) {
      print("-------------------------");
      print("error connection.dart 27");
      print(e);
      throw e;
    }
  }

  dispose() {
    _subscription.cancel();
    connected.close();
  }
}
