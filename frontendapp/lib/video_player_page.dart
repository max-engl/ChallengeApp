import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';
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
  final List<int> _videoIndices = List.generate(30, (index) => index);
  Map<String, dynamic>? _currentVideoData;
  AuthService _authService = AuthService();
  VideoPlayerController? _currentController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _pageController.addListener(_onPageScroll);
  }

  Future<void> getVideoMetaData(int index) async {
    var ip = _authService.baseUrl;
    final metadataUrl = "$ip/api/videos/videoData/$index";

    final response = await http.get(Uri.parse(metadataUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _currentVideoData = {
          "id": data["videoid"],
          'username': data['userName'] ?? 'Unknown User',
          'description': data['description'] ?? 'No description',
          'likes': data['likes'] ?? 0,
          'dislikes': data['dislikes'] ?? 0,
        };
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

  void _loadController(int index) {
    if (_controllers.containsKey(index)) return;

    var ip = _authService.baseUrl;
    final videoUrl = "$ip/api/videos/video/$index";

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

        _currentController?.pause();
        _currentController = _controllers[_currentPage];
        _currentController?.play();

        getVideoMetaData(_videoIndices[page]);

        if (!_controllers.containsKey(page - 1) && page - 1 >= 0) {
          _loadController(_videoIndices[page - 1]);
        }
        if (!_controllers.containsKey(page + 1) &&
            page + 1 < _videoIndices.length) {
          _loadController(_videoIndices[page + 1]);
        }

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
                          _controllers[index] != null &&
                                  _controllers[index]!.value.isInitialized &&
                                  _controllers[index]!.value.isPlaying == false
                              ? Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color:
                                            const Color.fromARGB(94, 0, 0, 0),
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 55,
                                      ),
                                    ),
                                  ))
                              : Text("")
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up,
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
                      icon: const Icon(Icons.thumb_down,
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
                  _currentVideoData?['username'] ?? 'Username',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentVideoData?['description'] ?? 'Description',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
