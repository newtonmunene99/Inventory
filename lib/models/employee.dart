import 'package:flutter/foundation.dart';
import './shop.dart';
import './role.dart';

class Employee {
  final String name;
  final List<Shop> shops;
  final String email;
  final Role roles;
  final bool active;

  const Employee({
    @required this.name,
    @required this.shops,
    @required this.email,
    @required this.active,
    this.roles,
  });
}
