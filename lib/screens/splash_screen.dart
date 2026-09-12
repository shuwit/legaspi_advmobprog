import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 1 Legaspi
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Enhancement 1 Legaspi
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Enhancement 1 Legaspi
    _checkAuthentication();
  }

  // Enhancement 1 Legaspi: persistent authentication check
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userData,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 1 Legaspi: custom splash UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/nuicon.jpeg',
                width: 140.w,
                height: 140.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.school,
                  size: 100.sp,
                  color: const Color(0xFF1A237E),
                ),
              ),
              SizedBox(height: 24.h),
              CustomText(
                text: 'Facebook Replication', // Enhancement 1 Legaspi
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              SizedBox(
                width: 28.w,
                height: 28.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
