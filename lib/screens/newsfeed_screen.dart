import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';
import 'detail_screen.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.getPosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = _postService.getPosts();
    });
    await _postsFuture;
  }

  void _openPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: CustomFont(
                    text: 'Error: ${snapshot.error}',
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: 120.h),
                const Center(
                  child: CustomFont(text: 'No posts yet.', fontSize: 14),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () => _openPost(post),
                onComment: () => _openPost(post),
              );
            },
          );
        },
      ),
    );
  }
}
