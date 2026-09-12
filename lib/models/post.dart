class Post {
  final int id;
  final int postId;
  final int userId;
  final String title; // Enhancement 2 Legaspi
  final String body;
  final int likes;
  final int dislikes;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.postId,
    required this.userId,
    this.title = '', // Enhancement 2 Legaspi
    required this.body,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? json['post_id'] ?? json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      title: json['title'] ?? '', // Enhancement 2 Legaspi
      body: json['body'] ?? '',
      likes: (json['reactions'] != null && json['reactions']['likes'] != null)
          ? (json['reactions']['likes'] as num).toInt()
          : (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['reactions'] != null && json['reactions']['dislikes'] != null)
          ? (json['reactions']['dislikes'] as num).toInt()
          : (json['dislikes'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'title': title, // Enhancement 2 Legaspi
      'body': body,
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Enhancement 3 Legaspi
  Post copyWith({
    int? id,
    int? postId,
    int? userId,
    String? title,
    String? body,
    int? likes,
    int? dislikes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
