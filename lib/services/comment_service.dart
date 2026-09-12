import 'dart:convert';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/comment.dart';

// Enhancement 3 Legaspi
class CommentService {
  // Enhancement 3 Legaspi
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    final response = await get(
      Uri.parse('$host/comments/post/$postId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List commentsJson = data['comments'] ?? [];
      return commentsJson.map((c) => Comment.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  // Enhancement 3 Legaspi
  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
  }) async {
    final response = await post(
      Uri.parse('$host/comments/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'body': body,
        'postId': postId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }
}
