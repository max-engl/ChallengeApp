import 'dart:convert';
import 'dart:io';
import 'package:frontendapp/SelectionScreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  final String baseUrl =
      'http://192.168.178.143:3005'; // Replace with your actual API URL
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Challenge>> fetchChallenges() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/videos/challenges'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  Future<void> createChallenge(String titel, String description) async {
    final url = Uri.parse('$baseUrl/api/videos/challenges/create');
    var token = await getToken();
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'titel': titel, 'description': description, "userId": token}),
    );
    if (response.statusCode == 201) {
      print("created succesfully");
    } else {
      print("error");
    }
  }

  Future<bool> dislikeVideo(String videoId) async {
    final url = Uri.parse('$baseUrl/api/videos/dislike');
    var token = await getToken();
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': token, 'videoId': videoId}),
    );
    if (response.statusCode == 200) {
      print("disliked succesfull");
      return true;
    } else {
      return false;
    }
  }

  Future<bool> likeVideo(String videoId) async {
    final url = Uri.parse('$baseUrl/api/videos/like');
    var token = await getToken();
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': token, 'videoId': videoId}),
    );
    if (response.statusCode == 200) {
      print("liked succesfull");
      return true;
    } else {
      return false;
    }
  }

  // Login function
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login/loginUser');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> loadUserData(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = null;
    if (username == "KEINER") {
      token = prefs.getString('token');
    }
    print(username);
    if (username == "KEINER") {
      // Fetch the user data from your API
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          "username": userData['user']['userName'], // Access the correct key
          "profilePicture": userData['user']
              ['profilePicture'], // Access the correct key
          "videos": userData['videos'], // Include videos
        };
      } else {
        print('Failed to load user data');
      }
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userName": username}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          "username": userData['user']['userName'], // Access the correct key
          "profilePicture": userData['user']
              ['profilePicture'], // Access the correct key
          "videos": userData['videos'], // Include videos
        };
      } else {
        print('Failed to load user data');
      }
    }
    return {}; // Return an empty Map if no token is available
  }

  // Register function with image upload
  Future<bool> register(String email, String password, File? imageFile) async {
    final url = Uri.parse('$baseUrl/api/login/registerUser');

    var request = http.MultipartRequest('POST', url);
    request.fields['userName'] = email;
    request.fields['password'] = password;

    // Log to see if the file exists
    print('File exists: ${imageFile?.existsSync()}');

    // Only add the image if it's available
    if (imageFile != null && imageFile.existsSync()) {
      String? mimeType = lookupMimeType(imageFile.path);
      var mimeTypeData = mimeType!.split('/');

      // Create multipart image upload
      var imageUpload = await http.MultipartFile.fromPath(
        'profilePic',
        imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      );

      request.files.add(imageUpload);
      print('Image added: ${imageFile.path}');
    } else {
      print('No image file provided');
    }

    // Sending the request and getting the response
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Log response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Logout function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
