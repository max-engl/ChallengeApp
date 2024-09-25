import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontendapp/UserScreen.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:visibility_detector/visibility_detector.dart';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  final Map<int, VideoPlayerController?> _controllers = {};
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final List<int> _videoIndices = List.generate(50, (index) => index);
  Map<String, dynamic>? _currentVideoData;
  final AuthService _authService = AuthService();
  VideoPlayerController? _currentController;
  int _currentPage = 0;
  String pictureUrl = 'https://placehold.co/200x200';
  String _currentUserName = "None";
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _pageController.addListener(_onPageScroll);
  }

  Future<void> getVideoMetaData(int index) async {
    var ip = _authService.baseUrl;
    final metadataUrl = "$ip/api/videos/videoData";

    final response = await http.post(
      Uri.parse(metadataUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userToken': await _authService.getToken(),
        "index": index,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _currentVideoData = {
          "id": data["videoid"],
          'username': data['userName'] ?? 'Unknown User',
          'description': data['description'] ?? 'No description',
          'likes': data['likes'] ?? 0,
          'dislikes': data['dislikes'] ?? 0,
          'challenge': data['challenge'] ?? "KEINE",
          'liked': data["liked"] ?? false,
          'disliked': data["disliked"] ?? false,
        };
        _currentUserName = data['userName'];
        if (_currentUserName.isNotEmpty) {
          pictureUrl = '$ip/api/user/profile-pic/$_currentUserName';
        } else {
          pictureUrl =
              'https://placehold.co/200x200'; // fallback in case URL is invalid
        }
      });
    } else {
      print("Failed to load video metadata");
    }
  }

  Future<void> _initializeControllers() async {
    for (int i = 0; i < 5; i++) {
      _loadController(_videoIndices[i]);
    }

    getVideoMetaData(_videoIndices[0]);
  }

  Future<String?> fetchVideoUrlByIndex(int index) async {
    var ip = _authService.baseUrl;
    final url = Uri.parse(
        '$ip/api/videos/video/$index'); // Modify the endpoint if necessary
    try {
      final response = await http.get(url);

      if (response.statusCode == 201) {
        return response
            .body; // Assuming the video URL is returned as the response body
      } else if (response.statusCode == 404) {
        print("Video not found");
        return null;
      } else if (response.statusCode == 405) {
        print("No videos available");
        return null;
      } else {
        print("Unexpected error: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error fetching video: $error");
      return null;
    }
  }

  Future<void> _loadController(int index) async {
    if (_controllers.containsKey(index)) return;

    var ip = _authService.baseUrl;
    final videoUrl = await fetchVideoUrlByIndex(index) ?? "";

    final controller = VideoPlayerController.network(videoUrl);
    controller.addListener(() {
      if (controller.value.isBuffering) {
        // Optionally handle buffering state
      } else if (controller.value.isInitialized) {
        // Optionally handle initialization state
      }
    });

    controller.initialize().then((_) {
      setState(() {
        _controllers[index] = controller;
        controller.setLooping(true);
        if (index == _currentPage) {
          controller.play();
        }
      });
    }).catchError((error) {
      print("Error initializing video controller: $error");
    });
  }

  void _disposeController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      final page = _pageController.page?.round() ?? 0;

      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });

        // Pause the current controller before switching
        _currentController?.pause();

        // Play the next video
        _currentController = _controllers[_currentPage];
        _currentController?.play();

        // Load the new video's metadata
        getVideoMetaData(_videoIndices[page]);

        // Preload the next and previous videos
        if (!_controllers.containsKey(page - 1) && page - 1 >= 0) {
          _loadController(_videoIndices[page - 1]);
        }
        if (!_controllers.containsKey(page + 1) &&
            page + 1 < _videoIndices.length) {
          _loadController(_videoIndices[page + 1]);
        }

        // Dispose of controllers that are too far from the current page
        for (var key in _controllers.keys.toList()) {
          if (key < page - 2 || key > page + 2) {
            _disposeController(key);
          }
        }
      }
    }
  }

  void _togglePlayPause() {
    if (_currentController != null && _currentController!.value.isInitialized) {
      setState(() {
        if (_currentController!.value.isPlaying) {
          _currentController!.pause();
        } else {
          _currentController!.play();
        }
      });
    }
  }

  void _likeVideo() async {
    var ip = _authService.baseUrl;
    final likeUrl = "$ip/api/videos/like/${_currentVideoData?['id']}";
    try {
      final response = await http.post(Uri.parse(likeUrl));
      if (response.statusCode == 200) {
        setState(() {
          _currentVideoData?['likes'] += 1; // Update the likes count
        });
      } else {
        print("Failed to like the video");
      }
    } catch (error) {
      print("Error liking the video: $error");
    }
  }

  void _dislikeVideo() async {
    var ip = _authService.baseUrl;
    final dislikeUrl = "$ip/api/videos/dislike/${_currentVideoData?['id']}";
    try {
      final response = await http.post(Uri.parse(dislikeUrl));
      if (response.statusCode == 200) {
        setState(() {
          _currentVideoData?['dislikes'] += 1; // Update the dislikes count
        });
      } else {
        print("Failed to dislike the video");
      }
    } catch (error) {
      print("Error disliking the video: $error");
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller?.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _videoIndices.length,
        itemBuilder: (context, index) {
          return _buildVideoWithOverlay(index);
        },
      ),
    );
  }

  Widget _buildVideoWithOverlay(int index) {
    return Stack(
      children: [
        VisibilityDetector(
          key: Key('video_$index'),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction == 0) {
              _controllers[index]?.pause();
            } else {
              _controllers[index]?.play();
            }
          },
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.black,
              child: Center(
                child: _controllers[index] != null &&
                        _controllers[index]!.value.isInitialized
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controllers[index]!.value.size.width,
                              height: _controllers[index]!.value.size.height,
                              child: VideoPlayer(_controllers[index]!),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VideoProgressIndicator(
                              _controllers[index]!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Color.fromARGB(255, 188, 255, 144),
                                backgroundColor: Colors.black54,
                                bufferedColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Background color
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: UserScreen(
                        username: _currentUserName,
                      ),
                      withNavBar: true, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: Container(
                    width: 65.0,
                    height: 65.0,
                    decoration: BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: DecorationImage(
                        image: NetworkImage(pictureUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: _currentVideoData != null &&
                              _currentVideoData?["liked"]
                          ? const Icon(Icons.thumb_up,
                              color: Colors.green, size: 40)
                          : const Icon(Icons.thumb_up,
                              color: Colors.white, size: 40),
                      onPressed: () async {
                        var success = await _authService
                            .likeVideo(_currentVideoData?["id"]);
                        if (success) {
                          getVideoMetaData(_videoIndices[_currentPage]);
                        }
                      },
                    ),
                    Text(
                      _currentVideoData != null
                          ? _currentVideoData!['likes'].toString()
                          : '0',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Space between buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: _currentVideoData != null &&
                              _currentVideoData?["disliked"]
                          ? const Icon(Icons.thumb_down,
                              color: Colors.red, size: 40)
                          : const Icon(Icons.thumb_down,
                              color: Colors.white, size: 40),
                      onPressed: () async {
                        var success = await _authService
                            .dislikeVideo(_currentVideoData?["id"]);
                        if (success) {
                          getVideoMetaData(_videoIndices[_currentPage]);
                        }
                      },
                    ),
                    Text(
                      _currentVideoData != null
                          ? _currentVideoData!['dislikes'].toString()
                          : '0',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$_currentUserName' ?? 'Username',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _currentVideoData?['challenge'] ?? 'Challenge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentVideoData?['description'] ?? 'Description',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
