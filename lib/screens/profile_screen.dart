import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/login_type.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

// Enhancement 3 Legaspi
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Enhancement 3 Legaspi
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  late Future<User> _userFuture;
  Future<List<Post>>? _postsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _userFuture = _userService.getUser();
    });
    await _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final userData = await _userService.getUserData();
    final loginType = LoginTypeX.fromStorage(userData['loginType']?.toString());
    final userId = userData['id'] as int? ?? 0;

    // Enhancement 3 Legaspi: DummyJSON posts only when DummyJSON login
    if (loginType == LoginType.dummyJson && userId > 0) {
      setState(() {
        _postsFuture = _postService.getPostsByUserId(userId);
      });
    } else {
      setState(() {
        _postsFuture = Future.value(<Post>[]);
      });
    }
  }

  void _openPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
    );
  }

  // Enhancement 3 Legaspi
  Future<void> _updateUsername() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == null || confirmed.isEmpty) return;
    try {
      await _userService.updateUsername(username: confirmed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated')),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  // Enhancement 3 Legaspi
  Future<void> _changePassword(User user) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentCtrl.text,
        newPassword: newCtrl.text,
        email: user.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password change failed: $e')),
      );
    }
  }

  // Enhancement 3 Legaspi
  Future<void> _deleteAccount(User user) async {
    final passwordCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion.'),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await _userService.deleteAccount(
        email: user.email,
        password: passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 3 Legaspi
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: CustomFont(text: 'Error: ${snapshot.error}', fontSize: 14),
          );
        }

        final user = snapshot.data!;
        final isFirebase = user.loginType == LoginType.firebase;

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: EdgeInsets.only(bottom: 80.h),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                color: const Color(0xFF1877F2),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48.r,
                      backgroundColor: Colors.white,
                      backgroundImage: user.image.isNotEmpty
                          ? CachedNetworkImageProvider(user.image)
                          : null,
                      child: user.image.isEmpty
                          ? Icon(Icons.person, size: 48.sp, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    CustomFont(
                      text: user.fullName.isNotEmpty
                          ? user.fullName
                          : user.username,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    CustomFont(
                      text: '@${user.username}',
                      fontSize: 13,
                      color: Colors.white70,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    // Enhancement 3 Legaspi: show LoginType
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomFont(
                        text: 'Login: ${user.loginType.label}',
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Enhancement 3 Legaspi: details depending on LoginType
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: 'Account Details',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        _detailRow('Email', user.email),
                        if (isFirebase) ...[
                          _detailRow('Age', '${user.age}'),
                          _detailRow('Contact No', user.contactNo),
                        ] else ...[
                          _detailRow('Gender', user.gender),
                          _detailRow('User ID', '#${user.id}'),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Enhancement 3 Legaspi: account actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const CustomFont(
                        text: 'Update Username',
                        fontSize: 14,
                      ),
                      onTap: _updateUsername,
                    ),
                    if (isFirebase) ...[
                      ListTile(
                        leading: const Icon(Icons.lock_reset),
                        title: const CustomFont(
                          text: 'Change Password',
                          fontSize: 14,
                        ),
                        onTap: () => _changePassword(user),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        title: const CustomFont(
                          text: 'Delete Account',
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                        onTap: () => _deleteAccount(user),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isFirebase) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  child: const CustomFont(
                    text: 'My Posts',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_postsFuture == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  FutureBuilder<List<Post>>(
                    future: _postsFuture,
                    builder: (context, postSnapshot) {
                      if (postSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.all(24.r),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (postSnapshot.hasError) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: CustomFont(
                            text: 'Error loading posts: ${postSnapshot.error}',
                            fontSize: 13,
                          ),
                        );
                      }

                      final posts = postSnapshot.data ?? [];
                      if (posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CustomFont(
                            text: 'No posts found for this user.',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        );
                      }

                      return Column(
                        children: posts.map((post) {
                          return PostCard(
                            post: post,
                            authorName: user.fullName,
                            authorImage: user.image,
                            onTap: () => _openPost(post),
                            onComment: () => _openPost(post),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: CustomFont(text: label, fontSize: 12, color: Colors.grey),
          ),
          Expanded(
            child: CustomFont(
              text: value.isEmpty ? '-' : value,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
