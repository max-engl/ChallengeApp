import 'package:flutter/material.dart';
import 'package:frontendapp/QuestScreen.dart';
import 'package:frontendapp/StartPage.dart';
import 'package:frontendapp/UserScreen.dart';
import 'package:frontendapp/upload_video_page.dart';
import 'package:frontendapp/video_player_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      Startpage(),
      UploadVideoPage(),
      VideoStreamPage(),
      Userscreen(),
    ];
  }

  // Define your bottom nav bar items
  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        activeColorPrimary: const Color.fromARGB(255, 188, 255, 144),
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        activeColorPrimary: const Color.fromARGB(255, 188, 255, 144),
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.movie),
        activeColorPrimary: const Color.fromARGB(255, 188, 255, 144),
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        activeColorPrimary: const Color.fromARGB(255, 188, 255, 144),
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      backgroundColor: const Color.fromARGB(171, 41, 41, 41),
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          colorBehindNavBar: Colors.transparent),
      navBarStyle: NavBarStyle.style6,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 350),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      // Add the animation here
    );
  }
}

// Example screens
class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Screen 1'));
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Screen 2'));
  }
}

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Screen 3'));
  }
}
