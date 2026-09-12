import 'dart:convert';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/post.dart';

class PostService {
  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    final response = await get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      return postsJson.map((p) => Post.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  // Enhancement 2 Legaspi: posts by user id
  Future<List<Post>> getPostsByUserId(int userId, {int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts/user/$userId?limit=$limit&skip=$skip');
    final response = await get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      return postsJson.map((p) => Post.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load user posts: ${response.statusCode}');
    }
  }

  // Enhancement 3 Legaspi
  Future<Post> getPostById(int id) async {
    final response = await get(
      Uri.parse('$host/posts/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load post: ${response.statusCode}');
    }
  }
}
