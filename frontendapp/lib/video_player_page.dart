import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  VideoPlayerController? _controller;
  bool _isBuffering = true;
  int _currentIndex = 0;
  Timer? _scrollTimer;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final List<int> _videoIndices = List.generate(10, (index) => index);

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _pageController.addListener(_onPageScroll);
  }

  Future<void> _initializeVideoPlayer({bool loadImmediately = true}) async {
    final url = "http://192.168.178.169:3005/api/videos/video/$_currentIndex";

    try {
      // Debug statement to indicate that a request is being made
      print('Requesting video $_currentIndex from server: $url');

      // Dispose of the current controller if it exists
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.dispose();
      }

      // Initialize the main controller for the current video
      _controller = VideoPlayerController.network(url);

      // If loadImmediately is true, initialize and play the video
      if (loadImmediately) {
        await _controller!.initialize();
        setState(() {
          _isBuffering = false;
        });
        _controller?.play();
      }
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _onPageScroll() {
    // Cancel any previous scroll timer
    _scrollTimer?.cancel();

    // Start a new timer to check for scroll stop
    _scrollTimer = Timer(Duration(milliseconds: 50), () {
      if (_pageController.hasClients) {
        final page = _pageController.page?.round() ?? 0;

        if (_currentIndex != page) {
          setState(() {
            _currentIndex = page;
            _isBuffering = true;
          });

          // Dispose of the current video and load the new video
          _initializeVideoPlayer();

          // Add more video indices if we reach the end
          if (page >= _videoIndices.length - 1) {
            setState(() {
              _videoIndices.addAll(
                  List.generate(10, (index) => _videoIndices.length + index));
            });
          }
        }
      }
    });
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
          if (index == _currentIndex) {
            return _buildVideoPlayer();
          } else {
            return _buildPlaceholder();
          }
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
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
                  if (_isBuffering) Center(child: CircularProgressIndicator()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.red,
                        backgroundColor: Colors.black54,
                        bufferedColor: Colors.grey,
                      ),
                    ),
                  ),
                  _buildPlayPauseButton(),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Loading...',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller?.pause();
            } else {
              _controller?.play();
            }
          });
        },
        child: Icon(
          _controller?.value.isPlaying ?? false
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
