// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontendapp/HomePage.dart';
import 'upload_video_page.dart';
import 'video_player_page.dart';

void main() {
  runApp(VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Homepage(),
    );
  }
}
