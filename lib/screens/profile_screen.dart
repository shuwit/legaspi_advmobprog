import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 3 Legaspi
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Enhancement 3 Legaspi
  final UserService _userService = UserService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    // Enhancement 3 Legaspi
    _userFuture = _userService.getUser();
  }

  // Enhancement 3 Legaspi
  Future<void> _logout() async {
    try {
      await _userService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 3 Legaspi: custom profile UI
    return SafeArea(
      child: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: 'Error: ${snapshot.error}',
                fontSize: 14.sp,
              ),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user.image.isNotEmpty
                            ? NetworkImage(user.image)
                            : null,
                        child: user.image.isEmpty
                            ? Icon(Icons.person, size: 48.sp)
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: user.fullName,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text: '@${user.username}',
                        fontSize: 14.sp,
                        color: const Color(0xFFFFC107),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      Divider(height: 1.h, color: Colors.grey.shade200),
                      _ProfileInfoRow(
                        icon: Icons.wc_outlined,
                        label: 'Gender',
                        value: user.gender,
                      ),
                      Divider(height: 1.h, color: Colors.grey.shade200),
                      _ProfileInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'User ID',
                        value: '#${user.id}',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.logout, color: Colors.white, size: 20.sp),
                    label: CustomText(
                      text: 'Log Out',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Enhancement 3 Legaspi
class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: value,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
