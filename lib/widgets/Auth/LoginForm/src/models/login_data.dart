import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

class LoginData {
  final String? name;
  final String? fullName;
  final String? password;

  LoginData({
    @required this.name,
    this.fullName,
    @required this.password,
  });

  @override
  String toString() {
    return '$runtimeType($name, $fullName, $password)';
  }

  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name && fullName == other.fullName && password == other.password;
    }
    return false;
  }

  int get hashCode => hash2(name, password);
}
