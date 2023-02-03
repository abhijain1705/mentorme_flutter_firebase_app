import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/screens/post_screen.dart';
import 'package:mentor_me/features/home/screens/user_profile.dart';
import 'package:mentor_me/features/home/screens/users_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref
            .watch(authControllerProvider.notifier)
            .isOnlineStatus(true, context);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref
            .watch(authControllerProvider.notifier)
            .isOnlineStatus(false, context);
        break;
    }
  }

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? PostScreen(onTapped: onTabTapped,) : _currentIndex == 1 ? UserScreen() : UserProfile(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: new Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: new Icon(Icons.group), label: "group"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile")
        ],
      ),
    );
  }
}
