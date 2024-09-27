import 'package:flutter/material.dart';
import 'package:frontendapp/SettingsScreen.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class UserScreen extends StatefulWidget {
  final String? username; // Optional username parameter

  const UserScreen({super.key, this.username}); // Accept optional username

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final AuthService _authService = AuthService();
  bool isYourAccount = true; // Track if it's the user's account
  Map<String, dynamic> userInfo = {
    "username": "None",
    "profilePicture": null,
  };
  List<dynamic> videos = []; // Store video data (thumbnails)

  @override
  void initState() {
    super.initState();
    loadData(); // Load data initially
  }

  Future<void> loadData() async {
    try {
      print("Loading data..."); // Debugging print statemen
      isYourAccount = widget.username == null;
      String name = "KEINER";
      if (!isYourAccount) {
        name = widget.username ?? "KEINER";
      }
      final data = await _authService.loadUserData(name); // Fetch user data
      setState(() {
        isYourAccount = widget.username == null; // Update based on username
        userInfo['username'] = widget.username ?? data['username'] ?? "None";
        userInfo['profilePicture'] = data['profilePicture'];
        videos = data['videos'] ?? []; // Load the videos (thumbnails)
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
        actions: [
          // Conditionally display the action based on username
          if (isYourAccount)
            IconButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: Settingsscreen(),
                    withNavBar: true, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey,
                ))
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadData, // Call loadData when refreshing
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
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
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 7,
                  childAspectRatio: 0.5625,
                ),
                itemCount: videos.length, // Use the number of videos
                itemBuilder: (BuildContext context, int index) {
                  // Get the thumbnail URL for each video
                  String thumbnailUrl = videos[index]['thumbnailUrl'] ?? '';

                  return Container(
                    color: Colors.grey,
                    height: 160,
                    width: 90,
                    child: thumbnailUrl.isNotEmpty
                        ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                        : const Center(
                            child: Text(
                              'No Thumbnail',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
