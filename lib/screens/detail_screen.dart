import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';

// Enhancement 3 Legaspi
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.post});

  final Post post;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Enhancement 3 Legaspi
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Enhancement 3 Legaspi
    _commentsFuture = _commentService.getCommentsByPostId(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _refreshComments() async {
    setState(() {
      _commentsFuture = _commentService.getCommentsByPostId(widget.post.id);
    });
    await _commentsFuture;
  }

  // Enhancement 3 Legaspi
  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final userData = await _userService.getUserData();
      final userId = userData['id'] as int? ?? 0;
      await _commentService.addComment(
        body: text,
        postId: widget.post.id,
        userId: userId,
      );
      _commentController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added')),
      );
      await _refreshComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomFont(
          text: 'Post',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshComments,
              child: ListView(
                padding: EdgeInsets.only(bottom: 16.h),
                children: [
                  PostCard(post: widget.post),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: const CustomFont(
                      text: 'Comments',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Enhancement 3 Legaspi
                  FutureBuilder<List<Comment>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.all(24.r),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: CustomFont(
                            text: 'Error: ${snapshot.error}',
                            fontSize: 13,
                          ),
                        );
                      }

                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: const CustomFont(
                            text: 'No comments yet. Be the first to comment!',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        );
                      }

                      return Column(
                        children: comments.map((comment) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.person, size: 18.sp),
                            ),
                            title: CustomFont(
                              text: comment.fullName.isNotEmpty
                                  ? comment.fullName
                                  : (comment.username.isNotEmpty
                                      ? comment.username
                                      : 'User ${comment.userId}'),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            subtitle: CustomFont(
                              text: comment.body,
                              fontSize: 12,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.thumb_up_alt_outlined, size: 14.sp, color: Colors.grey),
                                SizedBox(width: 4.w),
                                CustomFont(
                                  text: '${comment.likes}',
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Enhancement 3 Legaspi: add comment input
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: _isSubmitting ? null : _addComment,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send, color: const Color(0xFF1877F2), size: 22.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
