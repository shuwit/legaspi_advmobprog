import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/login_type.dart';
import '../models/user.dart';

// Enhancement 1 Legaspi
ValueNotifier<UserService> userService = ValueNotifier(UserService());

// Enhancement 1 Legaspi: authenticate user and save with shared_preferences
class UserService {
  Map<String, dynamic> data = {};

  // Enhancement 1 Legaspi: Firebase Auth
  final fa.FirebaseAuth firebaseAuth = fa.FirebaseAuth.instance;

  fa.User? get currentUser => firebaseAuth.currentUser;

  Stream<fa.User?> get authStateChanges => firebaseAuth.authStateChanges();

  static const _sessionKeys = [
    'id',
    'username',
    'email',
    'firstName',
    'lastName',
    'gender',
    'image',
    'accessToken',
    'refreshToken',
    'token',
    'age',
    'contactNo',
    'loginType',
  ];

  // Enhancement 1 Legaspi / previous DummyJSON login
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      data['loginType'] = LoginType.dummyJson.storageValue;
      await saveUserData(data);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // Enhancement 2 Legaspi: profile cache key (survives logout)
  String _firebaseProfileKey(String email) =>
      'fb_profile_${email.trim().toLowerCase()}';

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // Enhancement 2 Legaspi: store age/contact inside Firebase Auth photoURL
  String _encodeFirebaseProfileMeta({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
  }) {
    return Uri(
      scheme: 'https',
      host: 'legaspi.app',
      path: '/profile',
      queryParameters: {
        'fName': fName,
        'lName': lName,
        'age': '$age',
        'contactNo': contactNo,
        'username': username,
      },
    ).toString();
  }

  // Enhancement 2 Legaspi
  Map<String, dynamic> _decodeFirebaseProfileMeta(String? photoURL) {
    if (photoURL == null || photoURL.isEmpty) return {};
    try {
      final uri = Uri.parse(photoURL);
      if (uri.host != 'legaspi.app') {
        return {'image': photoURL};
      }
      return {
        'firstName': uri.queryParameters['fName'] ?? '',
        'lastName': uri.queryParameters['lName'] ?? '',
        'age': _asInt(uri.queryParameters['age']),
        'contactNo': uri.queryParameters['contactNo'] ?? '',
        'username': uri.queryParameters['username'] ?? '',
        'image': '',
      };
    } catch (_) {
      return {};
    }
  }

  // Enhancement 2 Legaspi: keep age/contact/name after logout+login
  Future<void> _cacheFirebaseProfile(Map<String, dynamic> userData) async {
    final email = (userData['email'] ?? '').toString().trim().toLowerCase();
    if (email.isEmpty) return;

    final age = _asInt(userData['age']);
    final contactNo = (userData['contactNo'] ?? '').toString();
    final firstName =
        (userData['firstName'] ?? userData['fName'] ?? '').toString();
    final lastName =
        (userData['lastName'] ?? userData['lName'] ?? '').toString();

    // Never overwrite a good cache with empty profile values
    final existing = await _loadCachedFirebaseProfile(email);
    final cache = {
      'username': (userData['username'] ?? existing['username'] ?? '').toString(),
      'email': email,
      'firstName': firstName.isNotEmpty
          ? firstName
          : (existing['firstName'] ?? '').toString(),
      'lastName':
          lastName.isNotEmpty ? lastName : (existing['lastName'] ?? '').toString(),
      'age': age > 0 ? age : _asInt(existing['age']),
      'contactNo':
          contactNo.isNotEmpty ? contactNo : (existing['contactNo'] ?? '').toString(),
      'image': (userData['image'] ?? existing['image'] ?? '').toString(),
      'loginType': LoginType.firebase.storageValue,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firebaseProfileKey(email), jsonEncode(cache));
  }

  // Enhancement 2 Legaspi
  Future<Map<String, dynamic>> _loadCachedFirebaseProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_firebaseProfileKey(email));
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      map['age'] = _asInt(map['age']);
      return map;
    } catch (_) {
      return {};
    }
  }

  // Enhancement 2 Legaspi
  Future<void> _persistFirebaseProfileMeta(Map<String, dynamic> userData) async {
    final user = currentUser;
    if (user == null) return;

    final username = (userData['username'] ?? user.displayName ?? '').toString();
    final fName = (userData['firstName'] ?? '').toString();
    final lName = (userData['lastName'] ?? '').toString();
    final age = _asInt(userData['age']);
    final contactNo = (userData['contactNo'] ?? '').toString();

    if (username.isNotEmpty) {
      await user.updateDisplayName(username);
    }

    // Save profile fields to Firebase Auth so they survive logout
    if (age > 0 || contactNo.isNotEmpty || fName.isNotEmpty || lName.isNotEmpty) {
      await user.updatePhotoURL(
        _encodeFirebaseProfileMeta(
          fName: fName,
          lName: lName,
          age: age,
          contactNo: contactNo,
          username: username,
        ),
      );
    }
    await user.reload();
  }

  /// **Save User Data to SharedPreferences**
  /// Save user data from API response based on User model
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    // Enhancement 2 Legaspi
    await prefs.setInt('age', user.age);
    await prefs.setString('contactNo', user.contactNo);
    await prefs.setString('loginType', user.loginType.storageValue);

    // Support generic token key if present in API response
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }

    // Enhancement 2 Legaspi: cache Firebase profile fields across logout
    if (user.loginType == LoginType.firebase) {
      await _cacheFirebaseProfile(user.toJson());
    }
  }

  /// Retrieve user data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Enhancement 3 Legaspi: merge Firebase Auth user when needed
    final loginType = LoginTypeX.fromStorage(prefs.getString('loginType'));
    final firebaseUser = currentUser;
    final meta = _decodeFirebaseProfileMeta(firebaseUser?.photoURL);

    final email =
        prefs.getString('email') ?? firebaseUser?.email ?? meta['email'] ?? '';
    final cached = email.toString().isNotEmpty
        ? await _loadCachedFirebaseProfile(email.toString())
        : <String, dynamic>{};

    final ageFromPrefs = prefs.getInt('age') ?? 0;
    final contactFromPrefs = prefs.getString('contactNo') ?? '';

    final data = {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ??
          meta['username'] ??
          firebaseUser?.displayName ??
          cached['username'] ??
          '',
      'email': email,
      'firstName': (prefs.getString('firstName')?.isNotEmpty ?? false)
          ? prefs.getString('firstName')
          : (meta['firstName'] ?? cached['firstName'] ?? ''),
      'lastName': (prefs.getString('lastName')?.isNotEmpty ?? false)
          ? prefs.getString('lastName')
          : (meta['lastName'] ?? cached['lastName'] ?? ''),
      'gender': prefs.getString('gender') ?? '',
      'image': (prefs.getString('image')?.isNotEmpty ?? false)
          ? prefs.getString('image')
          : (meta['image'] ?? cached['image'] ?? ''),
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'age': ageFromPrefs > 0
          ? ageFromPrefs
          : (_asInt(meta['age']) > 0
              ? _asInt(meta['age'])
              : _asInt(cached['age'])),
      'contactNo': contactFromPrefs.isNotEmpty
          ? contactFromPrefs
          : ((meta['contactNo'] ?? '').toString().isNotEmpty
              ? meta['contactNo']
              : (cached['contactNo'] ?? '')),
      'loginType': loginType.storageValue,
    };

    // Enhancement 2 Legaspi: only cache when we have real profile values
    if (loginType == LoginType.firebase &&
        (data['email'] as String).isNotEmpty &&
        (_asInt(data['age']) > 0 ||
            (data['contactNo'] as String).isNotEmpty)) {
      await _cacheFirebaseProfile(data);
      // Migrate current session data into Firebase Auth for next login
      if (_asInt(meta['age']) == 0 &&
          (meta['contactNo'] ?? '').toString().isEmpty &&
          currentUser != null) {
        await _persistFirebaseProfileMeta(data);
      }
    }

    return data;
  }

  /// Retrieve User model from SharedPreferences
  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  // Enhancement 2 / 3 Legaspi
  Future<LoginType> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return LoginTypeX.fromStorage(prefs.getString('loginType'));
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = LoginTypeX.fromStorage(prefs.getString('loginType'));

    // Enhancement 1 Legaspi: Firebase session
    if (loginType == LoginType.firebase) {
      return currentUser != null;
    }

    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  /// **Logout and Clear User Data**
  // Enhancement 1 Legaspi: clears session/token and Firebase auth
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginType = LoginTypeX.fromStorage(prefs.getString('loginType'));

      if (loginType == LoginType.firebase || currentUser != null) {
        await signOut();
      }

      // Enhancement 2 Legaspi: clear session only; keep fb_profile_* cache
      for (final key in _sessionKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  // ---------- Enhancement 1 Legaspi: Firebase Auth methods ----------

  Future<fa.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Enhancement 1 Legaspi: persist Firebase session locally
    final firebaseUser = credential.user;
    if (firebaseUser != null) {
      await firebaseUser.reload();
      final refreshed = firebaseAuth.currentUser ?? firebaseUser;
      final userEmail = (refreshed.email ?? email).trim().toLowerCase();

      // Enhancement 2 Legaspi: restore from Firebase meta + local cache
      final meta = _decodeFirebaseProfileMeta(refreshed.photoURL);
      final cached = await _loadCachedFirebaseProfile(userEmail);
      final displayName = refreshed.displayName ?? '';

      final age = _asInt(meta['age']) > 0
          ? _asInt(meta['age'])
          : _asInt(cached['age']);
      final contactNo = (meta['contactNo'] ?? '').toString().isNotEmpty
          ? meta['contactNo'].toString()
          : (cached['contactNo'] ?? '').toString();
      final firstName = (meta['firstName'] ?? '').toString().isNotEmpty
          ? meta['firstName'].toString()
          : (cached['firstName'] ?? '').toString();
      final lastName = (meta['lastName'] ?? '').toString().isNotEmpty
          ? meta['lastName'].toString()
          : (cached['lastName'] ?? '').toString();
      final username = displayName.isNotEmpty
          ? displayName
          : ((meta['username'] ?? cached['username'] ?? '').toString());

      await saveUserData({
        'id': 0,
        'username': username,
        'email': userEmail,
        'firstName': firstName,
        'lastName': lastName,
        'gender': '',
        'image': (meta['image'] ?? cached['image'] ?? '').toString(),
        'accessToken': await refreshed.getIdToken() ?? '',
        'refreshToken': '',
        'age': age,
        'contactNo': contactNo,
        'loginType': LoginType.firebase.storageValue,
      });
    }
    return credential;
  }

  Future<fa.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> updateUsername({required String username}) async {
    // Enhancement 1 / 3 Legaspi
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      await currentUser!.reload();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    // Enhancement 2 Legaspi: keep username in profile cache + Firebase meta
    final email = prefs.getString('email') ?? currentUser?.email ?? '';
    if (email.isNotEmpty) {
      final cached = await _loadCachedFirebaseProfile(email);
      cached['username'] = username;
      cached['email'] = email;
      cached['firstName'] = prefs.getString('firstName') ?? cached['firstName'] ?? '';
      cached['lastName'] = prefs.getString('lastName') ?? cached['lastName'] ?? '';
      cached['age'] = prefs.getInt('age') ?? _asInt(cached['age']);
      cached['contactNo'] =
          prefs.getString('contactNo') ?? cached['contactNo'] ?? '';
      await _cacheFirebaseProfile(cached);
      await _persistFirebaseProfileMeta(cached);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    // Enhancement 1 / 3 Legaspi
    fa.AuthCredential credential = fa.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firebaseProfileKey(email));
    for (final key in _sessionKeys) {
      await prefs.remove(key);
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    // Enhancement 1 / 3 Legaspi
    fa.AuthCredential credential = fa.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  // Enhancement 2 Legaspi: complete Firebase signup + local profile fields
  Future<Map<String, dynamic>> registerFirebaseUser({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    await createAccount(
      email: emailAddress,
      password: password,
    );

    final userMap = {
      'id': 0,
      'username': username,
      'email': emailAddress.trim().toLowerCase(),
      'firstName': fName,
      'lastName': lName,
      'gender': '',
      'image': '',
      'accessToken': await currentUser?.getIdToken() ?? '',
      'refreshToken': '',
      'age': age,
      'contactNo': contactNo,
      'loginType': LoginType.firebase.storageValue,
    };

    // Enhancement 2 Legaspi: save to Firebase Auth + local cache
    await _persistFirebaseProfileMeta(userMap);
    await saveUserData(userMap);
    return userMap;
  }
}
