import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool success = await _authService.register(email, password, _selectedImage);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful'),
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Display the selected image
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Text('No image selected'),

            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Profile Picture'),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
