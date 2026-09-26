import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/login_type.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 2 Legaspi
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Enhancement 2 Legaspi
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  // Enhancement 2 Legaspi: DummyJSON vs Firebase
  LoginType _loginType = LoginType.dummyJson;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Enhancement 2 Legaspi: authentication logic
  void _login() async {
    UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> response;

        if (_loginType == LoginType.firebase) {
          // Enhancement 2 Legaspi: Firebase Auth SDK
          await userService.signIn(
            email: _usernameController.text.trim(),
            password: _passwordController.text,
          );
          response = await userService.getUserData();
        } else {
          // Enhancement 2 Legaspi: DummyJSON API
          response = await userService.loginUser(
            _usernameController.text.trim(),
            _passwordController.text,
          );
          await userService.saveUserData(response);
        }

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 2 Legaspi: custom sign-in UI
    final isFirebase = _loginType == LoginType.firebase;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nuicon.jpeg',
                        width: 56.w,
                        height: 56.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.school,
                          size: 48.sp,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      CustomText(
                        text: 'Welcome',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Enhancement 2 Legaspi: choose auth provider
                  SegmentedButton<LoginType>(
                    segments: const [
                      ButtonSegment(
                        value: LoginType.dummyJson,
                        label: Text('DummyJSON'),
                        icon: Icon(Icons.api),
                      ),
                      ButtonSegment(
                        value: LoginType.firebase,
                        label: Text('Firebase'),
                        icon: Icon(Icons.local_fire_department),
                      ),
                    ],
                    selected: {_loginType},
                    onSelectionChanged: (value) {
                      setState(() => _loginType = value.first);
                    },
                  ),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: isFirebase
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: isFirebase ? 'Email' : 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return isFirebase
                            ? 'Please enter your email'
                            : 'Please enter your username';
                      }
                      if (isFirebase &&
                          (!value.contains('@') || !value.contains('.'))) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : CustomText(
                              text: 'Log In',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Enhancement 2 Legaspi
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: CustomText(
                      text: 'Create a Firebase account',
                      fontSize: 13.sp,
                      color: const Color(0xFF1877F2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
