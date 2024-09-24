import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';

class ChallengeSelectionScreen extends StatefulWidget {
  const ChallengeSelectionScreen({super.key});

  @override
  State<ChallengeSelectionScreen> createState() =>
      _ChallengeSelectionScreenState();
}

class _ChallengeSelectionScreenState extends State<ChallengeSelectionScreen> {
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _challenges = _authService.fetchChallenges(); // Fetch challenges from API
  }

  late Future<List<Challenge>> _challenges;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Challenge", style: TextStyle(color: Colors.grey)),
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      ),
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      body: FutureBuilder<List<Challenge>>(
        future: _challenges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load challenges: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Challenge>? challenges = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: challenges?.length ?? 0,
                itemBuilder: (context, index) {
                  final challenge = challenges![index];

                  return GestureDetector(
                      onTap: () {
                        Navigator.pop(context,
                            {"title": challenge.title, "id": challenge.id});
                      },
                      child: Card(
                        color: Color.fromARGB(255, 39, 39, 39),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      challenge.title.toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Spacer(), // Pushes the video count and icon to the right
                                  Icon(
                                    Icons.videocam,
                                    color: Colors
                                        .grey, // Set the icon color to match the theme
                                  ),
                                  SizedBox(
                                      width:
                                          5), // Space between icon and video count
                                  Text(
                                    challenge.videoCount.toString(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Divider(),
                              Text(
                                challenge.description,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ));
                },
              ),
            );
          } else {
            return Center(child: Text('No challenges available'));
          }
        },
      ),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int videoCount;

  Challenge(
      {required this.id,
      required this.title,
      required this.description,
      required this.videoCount});

  // Factory method to create a Challenge from JSON data
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'],
      title: json['titel'], // match the exact field names returned by the API
      description: json['description'],
      videoCount: json["videoCount"],
    );
  }
}
