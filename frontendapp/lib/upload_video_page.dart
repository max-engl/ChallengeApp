// lib/upload_video_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? _video;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _video = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;

    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.178.169:3005/api/videos/upload'));
    request.files.add(await http.MultipartFile.fromPath('video', _video!.path));
    request.fields['title'] = 'My Video';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _video == null
                ? Text('No video selected')
                : Text('Video selected: ${_video!.path}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick Video'),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadVideo,
                    child: Text('Upload Video'),
                  ),
          ],
        ),
      ),
    );
  }
}
