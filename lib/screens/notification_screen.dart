import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_font.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.favorite, color: const Color(0xFF1877F2), size: 20.sp),
          ),
          title: const CustomFont(
            text: 'Someone liked your post',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          subtitle: const CustomFont(text: 'Just now', fontSize: 11, color: Colors.grey),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.comment, color: const Color(0xFF1877F2), size: 20.sp),
          ),
          title: const CustomFont(
            text: 'New comment on a post',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          subtitle: const CustomFont(text: '1h ago', fontSize: 11, color: Colors.grey),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person_add, color: const Color(0xFF1877F2), size: 20.sp),
          ),
          title: const CustomFont(
            text: 'You have a new friend suggestion',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          subtitle: const CustomFont(text: 'Yesterday', fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
