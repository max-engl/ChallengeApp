import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
      backgroundColor: const Color.fromARGB(255, 17, 17, 17), // Dark background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome Text
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please fill in the details below",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Email TextField
                _buildTextField(
                  context,
                  _emailController,
                  "Email",
                  Icons.email,
                  false,
                ),
                const SizedBox(height: 20),

                // Password TextField
                _buildTextField(
                  context,
                  _passwordController,
                  "Password",
                  Icons.lock,
                  true,
                ),
                const SizedBox(height: 20),

                // Display the selected image
                _selectedImage != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Text(
                        'No image selected',
                        style: const TextStyle(color: Colors.grey),
                      ),

                // Button to select image
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Select Profile Picture',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable TextField for Email and Password
  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String labelText,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 39, 39, 39),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 188, 255, 144)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
