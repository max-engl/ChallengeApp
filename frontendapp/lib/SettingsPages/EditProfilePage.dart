import 'package:flutter/material.dart';

class Editprofilepage extends StatelessWidget {
  const Editprofilepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil bearbeiten',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
