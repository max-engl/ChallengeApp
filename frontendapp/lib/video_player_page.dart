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
  VideoPlayerController? _controller;
  bool _isBuffering = true;
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final List<int> _videoIndices = List.generate(10, (index) => index);
  Map<String, String>? _currentVideoData; // Holds metadata

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _pageController.addListener(_onPageScroll);
  }

  Future<void> _initializeVideoPlayer({bool loadImmediately = true}) async {
    final url = "http://192.168.178.98:3005/api/videos/video/$_currentIndex";
    final metadataUrl =
        "http://192.168.178.98:3005/api/videos/metadata/$_currentIndex";

    try {
      print('Requesting video $_currentIndex from server: $url');

      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.dispose();
      }

      _controller = VideoPlayerController.network(url)
        ..addListener(() {
          if (_controller!.value.isBuffering) {
            setState(() {
              _isBuffering = true;
            });
          } else if (_controller!.value.isInitialized) {
            setState(() {
              _isBuffering = false;
            });
          }
        });

      if (loadImmediately) {
        await _controller!.initialize();
        setState(() {
          _isBuffering = false;
        });
        _controller?.play();
      }

      // Fetch video metadata
      final response = await http.get(Uri.parse(metadataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentVideoData = {
            'username': data['username'],
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
    _controller?.dispose();
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
                List.generate(10, (index) => _videoIndices.length + index));
          });
        }
      }
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller?.pause();
        } else {
          _controller?.play();
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
              child: _controller != null && _controller!.value.isInitialized
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                        if (_isBuffering)
                          const Center(child: CircularProgressIndicator()),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VideoProgressIndicator(
                            _controller!,
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
          bottom: 100, // Adjust as needed
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
                '123', // Replace with actual like count
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100, // Adjust as needed
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
                '45', // Replace with actual dislike count
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
                  _currentVideoData?['username'] ??
                      'Username', // Replace with actual username
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentVideoData?['description'] ??
                      'Description', // Replace with actual description
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
