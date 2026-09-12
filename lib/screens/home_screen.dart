import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'product_screen.dart';
import 'cart_screen.dart'; // Enhancement 1 Legaspi
import 'profile_screen.dart'; // Enhancement 3 Legaspi
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  // Enhancement 3 Legaspi
  Map<String, dynamic> _userData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Enhancement 3 Legaspi: read saved/auth user data from route args
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _userData = args;
    }
  }

  String get _profileTitle {
    // Enhancement 3 Legaspi
    final firstName = _userData['firstName']?.toString() ?? '';
    if (firstName.isNotEmpty) return firstName;
    if (widget.username.isNotEmpty) return widget.username;
    return 'Profile';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          title: (_selectedIndex == 0)
              ? CustomText(
                  text: 'E-Commerce Shop',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                )
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart' // Enhancement 1 Legaspi
                      : (_selectedIndex == 2)
                          ? _profileTitle // Enhancement 3 Legaspi
                          : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            ProductScreen(),
            CartScreen(), // Enhancement 1 Legaspi
            ProfileScreen(), // Enhancement 3 Legaspi
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), // Enhancement 1 Legaspi
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
        ),
        // Enhancement 2 Legaspi: FloatingActionButton for Chat
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                onPressed: () {
                  // Chat action
                },
                backgroundColor: Colors.amber,
                child: const Icon(Icons.chat, color: Colors.black87),
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
