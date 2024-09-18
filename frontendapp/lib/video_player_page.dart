import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  List<VideoPlayerController> _controllers = [];
  bool _isBuffering = true;
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final List<int> _videoIndices = List.generate(2, (index) => index);
  Map<String, String>? _currentVideoData; // Holds metadata

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(first: true);
    _pageController.addListener(_onPageScroll);
  }

  Future<void> _initializeVideoPlayer({bool first = false}) async {
    int nextIndex = _currentIndex + 1;
    final urlone = "http://192.168.178.98:3005/api/videos/video/$_currentIndex";
    final urltwo = "http://192.168.178.98:3005/api/videos/video/$nextIndex";
    final metadataUrl =
        "http://192.168.178.98:3005/api/videos/videoData/$_currentIndex";

    try {
      // Dispose of the old controllers properly
      if (_controllers.length > 0) {
        for (var controller in _controllers) {
          if (controller.value.isInitialized) {
            controller.removeListener(() {}); // Remove all listeners
            controller.dispose();
          }
        }
        _controllers.clear();
      }

      // Initialize new controllers
      _controllers.add(VideoPlayerController.network(urlone)
        ..addListener(() {
          if (_controllers[0].value.isBuffering) {
            setState(() {
              _isBuffering = true;
            });
          } else if (_controllers[0].value.isInitialized) {
            setState(() {
              _isBuffering = false;
            });
          }
        }));

      _controllers.add(VideoPlayerController.network(urltwo)
        ..addListener(() {
          if (_controllers[1].value.isBuffering) {
            setState(() {
              _isBuffering = true;
            });
          } else if (_controllers[1].value.isInitialized) {
            setState(() {
              _isBuffering = false;
            });
          }
        }));

      await Future.wait([
        _controllers[0].initialize(),
        _controllers[1].initialize(),
      ]);

      setState(() {
        _isBuffering = false;
      });

      _controllers[0].play(); // Start playing the current video

      // Fetch video metadata
      final response = await http.get(Uri.parse(metadataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _currentVideoData = {
            'username': data['userName'],
            'description': data['description'],
          };
        });
      } else {
        print("Failed to load video metadata");
      }
    } catch (e) {
      print("Error initializing video player: $e");
      setState(() {
        _isBuffering = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      final page = _pageController.page?.round() ?? 0;

      if (_currentIndex != page) {
        setState(() {
          _currentIndex = page;
          _isBuffering = true;
        });

        _initializeVideoPlayer();

        if (page >= _videoIndices.length - 1) {
          setState(() {
            _videoIndices.addAll(
                List.generate(3, (index) => _videoIndices.length + index));
          });
        }
      }
    }
  }

  void _togglePlayPause() {
    if (_controllers.isNotEmpty && _controllers[0].value.isInitialized) {
      setState(() {
        if (_controllers[0].value.isPlaying) {
          _controllers[0].pause();
        } else {
          _controllers[0].play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Stream (Index $_currentIndex)"),
      ),
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
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            color: Colors.black,
            child: Center(
              child:
                  _controllers.isNotEmpty && _controllers[0].value.isInitialized
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controllers[0].value.size.width,
                                height: _controllers[0].value.size.height,
                                child: VideoPlayer(_controllers[0]),
                              ),
                            ),
                            if (_isBuffering)
                              const Center(child: CircularProgressIndicator()),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: VideoProgressIndicator(
                                _controllers[0],
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
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
        Positioned(
          bottom: 100,
          left: 20,
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up, color: Colors.white, size: 40),
                onPressed: () {
                  // Handle like button press
                },
              ),
              Text(
                '123',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_down, color: Colors.white, size: 40),
                onPressed: () {
                  // Handle dislike button press
                },
              ),
              Text(
                '45',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentVideoData?['username'] ?? 'Username',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentVideoData?['description'] ?? 'Description',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
