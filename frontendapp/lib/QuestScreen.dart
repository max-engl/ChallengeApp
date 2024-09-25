import 'package:flutter/material.dart';
import 'package:frontendapp/SelectionScreen.dart';
import 'package:frontendapp/challange_video_player.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Questscreen extends StatefulWidget {
  const Questscreen({super.key});

  @override
  State<Questscreen> createState() => _QuestscreenState();
}

class _QuestscreenState extends State<Questscreen> {
  final TextEditingController titelController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final AuthService _authService = AuthService();

  late Future<List<Challenge>> _challenges;

  @override
  void initState() {
    super.initState();
    _challenges = _authService.fetchChallenges(); // Fetch challenges from API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text(
          'Challange vorschlagen',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              style: TextStyle(color: Colors.grey), // Text color
              controller: titelController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.title, color: Colors.grey), // Icon color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                labelText: 'Challenge Titel',

                fillColor: Color.fromARGB(255, 39, 39, 39),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle:
                    TextStyle(color: Colors.grey, fontSize: 25), // Label color
              ),
            ),
            SizedBox(
              height: 50,
            ),
            TextField(
              style: TextStyle(color: Colors.grey), // Text color
              controller: descriptionController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.title, color: Colors.grey), // Icon color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                labelText: 'Challenge Beschreibung',

                fillColor: Color.fromARGB(255, 39, 39, 39),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle:
                    TextStyle(color: Colors.grey, fontSize: 25), // Label color
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 39, 39, 39), // Background color
                        foregroundColor: Colors.grey, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon:
                          Icon(Icons.upload, color: Colors.grey), // Icon color
                      label: const Text('Challenge veröffentlichen'),
                      onPressed: () async {
                        await _authService.createChallenge(
                            titelController.text, descriptionController.text);
                        setState(() {
                          _challenges = _authService.fetchChallenges();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            Row(children: <Widget>[
              Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "STIMME AB",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(child: Divider()),
            ]),
            Expanded(
              child: FutureBuilder<List<Challenge>>(
                future: _challenges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Failed to load challenges: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Challenge>? challenges = snapshot.data;

                    return ListView.builder(
                      itemCount: challenges?.length ?? 0,
                      itemBuilder: (context, index) {
                        final challenge = challenges![index];

                        return Card(
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

                                    IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.videocam,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        PersistentNavBarNavigator.pushNewScreen(
                                          context,
                                          screen: ChallengeVideoStreamPage(
                                              challengeId: challenge.id),
                                          withNavBar:
                                              true, // OPTIONAL VALUE. True by default.
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      },
                                    ),
                                    SizedBox(
                                        width:
                                            2), // Space between icon and video count
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
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No challenges available'));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
