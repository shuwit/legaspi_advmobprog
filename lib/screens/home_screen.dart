import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'newsfeed_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart'; // Enhancement 2 Legaspi
import '../widgets/custom_font.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  // Enhancement 1 Legaspi
  Map<String, dynamic> _userData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Enhancement 1 Legaspi
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _userData = args;
    }
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Newsfeed';
      case 1:
        return 'Notifications';
      case 2:
        final firstName = _userData['firstName']?.toString() ?? '';
        if (firstName.isNotEmpty) return firstName;
        if (widget.username.isNotEmpty) return widget.username;
        return 'Profile';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          elevation: 1,
          title: CustomFont(
            text: _title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 22.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            NewsfeedScreen(),
            NotificationScreen(),
            ProfileScreen(), // Enhancement 2 Legaspi
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF1877F2),
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}
