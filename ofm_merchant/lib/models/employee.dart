import './shop.dart';
import './role.dart';

class Employee {
  String name;
  List<Shop> shops;
  String email;
  Role roles;
  bool active;

  Employee({this.name, this.shops, this.email, this.active});
}
