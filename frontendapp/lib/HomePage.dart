import 'package:flutter/material.dart';
import 'package:frontendapp/upload_video_page.dart';
import 'package:frontendapp/video_player_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      UploadVideoPage(),
      VideoStreamPage(),
      Screen3(),
    ];
  }

  // Define your bottom nav bar items
  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: "Search",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications),
        title: "Notifications",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
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
      backgroundColor: Colors.white,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      navBarStyle: NavBarStyle.style9,
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
