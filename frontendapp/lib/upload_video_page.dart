import 'package:flutter/material.dart';
import 'package:frontendapp/SelectionScreen.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? _video;
  VideoPlayerController? _videoController;
  bool _isUploading = false;
  AuthService _authService = AuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedChallenge; // Holds the selected challenge

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _video = File(result.files.single.path!);
        if (_videoController != null) {
          _videoController!.dispose();
        }
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;

    setState(() {
      _isUploading = true;
    });
    var ip = _authService.baseUrl;
    var request =
        http.MultipartRequest('POST', Uri.parse('$ip/api/videos/upload'));
    request.files.add(await http.MultipartFile.fromPath('video', _video!.path));
    request.fields['title'] = _titleController.text;
    Map<String, dynamic> userInfo = await _authService.loadUserData();
    request.fields["userName"] = userInfo["username"];
    request.fields["description"] = _descriptionController.text;
    if (_selectedChallenge != null) {
      request.fields["challengeId"] = _selectedChallenge!;
    }
    var response = await request.send();

    if (response.statusCode == 201) {
      print("Video uploaded successfully!");
    } else {
      print("Failed to upload video.");
    }

    setState(() {
      _isUploading = false;
    });
  }

  Future<void> _openChallengeSelection() async {
    final selectedChallenge = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeSelectionScreen(), // New screen
      ),
    );

    if (selectedChallenge != null) {
      setState(() {
        _selectedChallenge = selectedChallenge;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        title: const Text(
          'Upload Video',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 350,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 39, 39, 39),
                  ),
                  child: _video == null
                      ? const Center(
                          child: Text('No video selected',
                              style: TextStyle(color: Colors.white)))
                      : _videoController != null &&
                              _videoController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : const Center(
                              child: Text('Initializing video...',
                                  style: TextStyle(color: Colors.white))),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(color: Colors.grey),
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Video Title',
                  fillColor: Color.fromARGB(255, 39, 39, 39),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(color: Colors.grey),
                controller: _descriptionController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.description, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Video Description',
                  fillColor: Color.fromARGB(255, 39, 39, 39),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 39, 39, 39),
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        icon: Icon(Icons.how_to_vote, color: Colors.grey),
                        label: Text(
                          _selectedChallenge ??
                              'Noch keine Challenge ausgewählt',
                        ),
                        onPressed: _openChallengeSelection,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(right: 10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 39, 39, 39),
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        icon: Icon(Icons.movie, color: Colors.grey),
                        label: const Text('Select video'),
                        onPressed: _pickVideo,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(left: 10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 39, 39, 39),
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        icon: Icon(Icons.upload, color: Colors.grey),
                        label: const Text('Upload Video'),
                        onPressed: _uploadVideo,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
