import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/post.dart';
import 'custom_font.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.authorName,
    this.authorImage,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  final Post post;
  final String? authorName;
  final String? authorImage;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Enhancement 3 Legaspi
  late int _likes;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likes != widget.post.likes) {
      _likes = widget.post.likes;
      _liked = false;
    }
  }

  // Enhancement 3 Legaspi
  void _toggleLike() {
    setState(() {
      if (_liked) {
        _likes = (_likes - 1).clamp(0, 1 << 30);
        _liked = false;
      } else {
        _likes += 1;
        _liked = true;
      }
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.authorName ?? 'User ${widget.post.userId}';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: (widget.authorImage != null &&
                            widget.authorImage!.isNotEmpty)
                        ? CachedNetworkImageProvider(widget.authorImage!)
                        : null,
                    child: (widget.authorImage == null ||
                            widget.authorImage!.isEmpty)
                        ? Icon(Icons.person, size: 22.sp)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: author,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomFont(
                          text: 'User ID #${widget.post.userId}',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (widget.post.title.isNotEmpty) ...[
                CustomFont(
                  text: widget.post.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
              ],
              CustomFont(
                text: widget.post.body,
                fontSize: 13,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_alt,
                    size: 14.sp,
                    color: const Color(0xFF1877F2),
                  ),
                  SizedBox(width: 4.w),
                  CustomFont(text: '$_likes', fontSize: 12, color: Colors.grey),
                  const Spacer(),
                  CustomFont(
                    text: '${widget.post.dislikes} dislikes',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
              Divider(height: 20.h),
              Row(
                children: [
                  // Enhancement 3 Legaspi: clickable like
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                        color: _liked ? const Color(0xFF1877F2) : Colors.grey[700],
                        size: 18.sp,
                      ),
                      label: CustomFont(
                        text: 'Like',
                        fontSize: 13,
                        color: _liked ? const Color(0xFF1877F2) : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Enhancement 3 Legaspi
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onComment ?? widget.onTap,
                      icon: Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.grey[700],
                        size: 18.sp,
                      ),
                      label: CustomFont(
                        text: 'Comment',
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
