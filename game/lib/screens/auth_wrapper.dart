import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/providers/auth_provider.dart';
import 'package:teste/screens/home_screen.dart';
import 'package:teste/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
