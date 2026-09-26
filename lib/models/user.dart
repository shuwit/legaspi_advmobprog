// Enhancement 3 Legaspi
import 'login_type.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  // Enhancement 2 Legaspi
  final int age;
  final String contactNo;
  final LoginType loginType;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.age = 0, // Enhancement 2 Legaspi
    this.contactNo = '', // Enhancement 2 Legaspi
    this.loginType = LoginType.dummyJson, // Enhancement 2 Legaspi
  });

  // Enhancement 3 Legaspi
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? json['emailAddress'] ?? '',
      firstName: json['firstName'] ?? json['fName'] ?? '',
      lastName: json['lastName'] ?? json['lName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '') ?? 0,
      contactNo: json['contactNo']?.toString() ?? '',
      loginType: LoginTypeX.fromStorage(json['loginType']?.toString()),
    );
  }

  // Enhancement 3 Legaspi
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'age': age,
      'contactNo': contactNo,
      'loginType': loginType.storageValue,
    };
  }

  // Enhancement 3 Legaspi
  String get fullName => '$firstName $lastName'.trim();
}
