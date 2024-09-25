import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';

class UserScreen extends StatefulWidget {
  final String? username; // Optional username parameter

  const UserScreen({super.key, this.username}); // Accept optional username

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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
        // Use passed username if available, otherwise use the backend data or default to 'None'
        userInfo['username'] = widget.username ?? data['username'] ?? "None";
        userInfo['profilePicture'] = data['profilePicture'];
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var username = userInfo['username'];
    var ip = _authService.baseUrl;
    var profilePicUrl =
        username != null ? "$ip/api/user/profile-pic/$username" : null;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        title: Text(
          '@$username',
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profilePicUrl != null && profilePicUrl.isNotEmpty
                          ? NetworkImage(profilePicUrl)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '@$username',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: const [
                    Text(
                      "12",
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                    Text(
                      "Folgt",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: const [
                    Text(
                      "12",
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                    Text(
                      "Follower",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: const [
                    Text(
                      "12",
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                    Text(
                      "Likes",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.5625,
              ),
              itemCount: 8,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  color: Colors.grey,
                  height: 160,
                  width: 90,
                  child: const Center(
                    child: Text(
                      'Item',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
                onPressed: () {
                  _authService.logout();
                },
                child: Text("logout"))
          ],
        ),
      ),
    );
  }
}
