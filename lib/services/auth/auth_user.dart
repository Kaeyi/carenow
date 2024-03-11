import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable //any subclasses of this class need to be immutable, they cannot have any fields tat change
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(email: user.email!, isEmailVerified: user.emailVerified,);
}
