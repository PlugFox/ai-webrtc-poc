import 'package:flutter/material.dart';

@immutable
final class SignInData {
  const SignInData({
    required this.username,
  });

  /// Username.
  final String username;
}
