import 'package:flutter/material.dart';
import 'package:frontendapp/LoginScreen.dart';
import 'package:frontendapp/SettingsPages/EditProfilePage.dart';
import 'package:frontendapp/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Account',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(context, 'Profil bearbeiten', Icons.edit, () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: Editprofilepage(),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 20),
            Text(
              'Allgemein',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(context, 'Äußerliches', Icons.color_lens, () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: Editprofilepage(),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 20),
            Text(
              'Über',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(
              context,
              'AGBs',
              Icons.description,
              () {
                // Action for appearance settings
                print("Appearance tapped");
              },
            ),
            _buildSettingItem(context, 'Datenschutz', Icons.policy, () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: Editprofilepage(),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }),
            _buildSettingItem(context, 'Support', Icons.help, () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: Editprofilepage(),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  AuthService().logout();
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.grey),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color.fromARGB(255, 39, 39, 39),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap, // Call the onTap function passed
      ),
    );
  }
}
