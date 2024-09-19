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
    var ip = _authService.baseUrl;
    var profilePicUrl = userInfo['username'] != null
        ? "$ip/api/user/profile-pic/" + username
        : null;

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 17, 17, 17), // Match background color
      appBar: AppBar(
        title: const Text(
          'User Screen',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
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
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider, // Fallback to default image
            ),
            const SizedBox(height: 20),
            // Display the username
            Text(
              'Username: $username',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.grey, // Match the text color
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 39, 39, 39), // Background color
                foregroundColor: Colors.grey, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                await _authService
                    .logout(); // Correctly invoke the logout function
                Navigator.pushReplacementNamed(context, "login");
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
