import 'package:flutter/material.dart';
import 'package:frontendapp/HomePage.dart';
import 'package:frontendapp/RegisterScreen.dart';
import 'package:frontendapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool success = await _authService.login(email, password);
    if (success) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 17, 17, 17), // Dark background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome Text
                const Text(
                  "Wilkommen zurück",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bitte melde dich an",
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
                  "Passwort",
                  Icons.lock,
                  true,
                ),
                const SizedBox(height: 40),
                // Login Button
                ElevatedButton(
                  onPressed: _login,
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
                    'Login',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                // Forgot Password Link
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Noch keinen Account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Registrieren",
                        style: TextStyle(
                          color: Color.fromARGB(255, 188, 255, 144),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
