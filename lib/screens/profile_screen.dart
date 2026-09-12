import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

// Enhancement 2 Legaspi
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Enhancement 1 / 2 Legaspi
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  late Future<User> _userFuture;
  Future<List<Post>>? _postsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser();
    // Enhancement 2 Legaspi: load posts by saved user id
    _loadUserPosts();
  }

  // Enhancement 2 Legaspi
  Future<void> _loadUserPosts() async {
    final userData = await _userService.getUserData();
    final userId = userData['id'] as int? ?? 0;
    setState(() {
      _postsFuture = _postService.getPostsByUserId(userId);
    });
  }

  void _openPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _userFuture = _userService.getUser();
            });
            await _loadUserPosts();
          },
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
                      text: user.fullName,
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
                    CustomFont(
                      text: user.email,
                      fontSize: 12,
                      color: Colors.white70,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: CustomFont(
                  text: 'My Posts', // Enhancement 2 Legaspi
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Enhancement 2 Legaspi: render posts by userId
              if (_postsFuture == null)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                FutureBuilder<List<Post>>(
                  future: _postsFuture,
                  builder: (context, postSnapshot) {
                    if (postSnapshot.connectionState == ConnectionState.waiting) {
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
                      return Padding(
                        padding: EdgeInsets.all(16.r),
                        child: const CustomFont(
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
          ),
        );
      },
    );
  }
}
