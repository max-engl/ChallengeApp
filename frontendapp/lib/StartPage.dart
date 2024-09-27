import 'package:flutter/material.dart';
import 'package:frontendapp/QuestScreen.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Startpage extends StatefulWidget {
  const Startpage({super.key});

  @override
  State<Startpage> createState() => _StartpageState();
}

class _StartpageState extends State<Startpage> {
  String userName = "Loading";

  Future<void> loadData() async {
    try {
      print("Loading data..."); // Debugging print statement
      final data =
          await AuthService().loadUserData("KEINER"); // Fetch user data
      setState(() {
        userName = data['username'] ?? "None";
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadData(); // Load data initially
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var ip = AuthService().baseUrl;
    var profilePicUrl =
        userName != null ? "$ip/api/user/profile-pic/$userName" : null;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.15),
        child: AppBar(
          toolbarHeight: screenHeight * 0.15,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.09, // Responsive avatar size
                backgroundImage:
                    profilePicUrl != null && profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
              ),
              SizedBox(width: screenWidth * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hallo",
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.05),
                  ),
                  Text(
                    userName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.09),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(100, 187, 255, 14),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.all(screenWidth * 0.02), // Responsive padding
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(
                        screenWidth * 0.02), // Responsive padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.25),
                        Text(
                          "Bereit für die heutige Challenge?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.02), // Space between text and card
                        SizedBox(
                          width: double.infinity,
                          height:
                              screenHeight * 0.2, // Fixed height for the card
                          child: Card(
                            elevation: 14,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth *
                                  0.05), // Responsive border radius
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black,
                                    Color.fromARGB(255, 159, 197, 65)
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      size: screenWidth *
                                          0.22, // Responsive icon size
                                      color: Color.fromARGB(255, 57, 88, 49),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.55,
                                      child: Text(
                                        "Fange einen Fisch und Brate ihn im Ofen",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 39, 39, 39), // Background color
                          foregroundColor: Colors.grey, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        icon: Icon(Icons.how_to_vote,
                            color: Colors.grey), // Icon color
                        label: const Text('Alle Challenges'),
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Questscreen(),
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
