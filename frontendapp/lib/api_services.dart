// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import './video.dart';

class ApiService {
  static const String apiUrl =
      'http://192.168.178.88:3005/api/videos'; // Replace with your backend URL

  // Fetch all videos from the backend
  static Future<List<Video>> fetchVideos() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List videos = json.decode(response.body);
      return videos.map((video) => Video.fromJson(video)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
