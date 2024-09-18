import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Userscreen extends StatefulWidget {
  const Userscreen({super.key});

  @override
  State<Userscreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<Userscreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic> userInfo = {
    "username": "None",
    "profilePicture": null, // Key to match backend response
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await _authService.loadUserData();
      setState(() {
        userInfo = data;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var username = userInfo['username'];
    var profilePicUrl = userInfo['username'] != null
        ? "http://192.168.178.98:3005/api/user/profile-pic/" + username
        : null;

    print('Profile Picture URL: $profilePicUrl'); // Debug print

    return Scaffold(
      appBar: AppBar(
        title: Text('User Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display profile picture if available
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePicUrl != null && profilePicUrl.isNotEmpty
                  ? NetworkImage(profilePicUrl)
                  : AssetImage('assets/default_profile.png')
                      as ImageProvider, // Fallback to default image
            ),
            SizedBox(height: 20),
            // Display the username
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService
                    .logout(); // Correctly invoke the logout function
                Navigator.pushReplacementNamed(context, "login");
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
