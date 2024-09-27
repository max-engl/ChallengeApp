// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontendapp/HomePage.dart';
import 'package:frontendapp/LoginScreen.dart';
import 'package:frontendapp/RegisterScreen.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'upload_video_page.dart';
import 'video_player_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return Homepage();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
