// Enhancement 3 Legaspi
class Comment {
  final int id;
  final String body;
  final int postId;
  final int likes;
  final int userId;
  final String username;
  final String fullName;

  Comment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.userId,
    required this.username,
    required this.fullName,
  });

  // Enhancement 3 Legaspi
  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return Comment(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      postId: json['postId'] ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      userId: user['id'] ?? json['userId'] ?? 0,
      username: user['username'] ?? '',
      fullName: user['fullName'] ?? '',
    );
  }

  // Enhancement 3 Legaspi
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'postId': postId,
      'likes': likes,
      'user': {
        'id': userId,
        'username': username,
        'fullName': fullName,
      },
    };
  }
}
