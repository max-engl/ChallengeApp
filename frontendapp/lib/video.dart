// lib/models/video.dart
class Video {
  final String title;
  final String videoUrl;

  Video({required this.title, required this.videoUrl});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'],
      videoUrl: json['videoUrl'],
    );
  }
}
