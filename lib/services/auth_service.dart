import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Current logged in user
  User? _currentUser;

  // Getter for current user
  User? get currentUser => _currentUser;

  // Login with username and password
  Future<User?> login(String username, String password) async {
    try {
      // Query users collection by username
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // User not found
      }

      // Get the first (and should be only) document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check password
      if (userData['password'] == password) {
        // Login successful
        _currentUser = User.fromMap(userData, userDoc.id);

        // Save login state
        await _saveLoginState(_currentUser!);

        return _currentUser;
      } else {
        return null; // Wrong password
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(User user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_username', user.username);
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Error saving login state: $e');
    }
  }

  // Check if user is already logged in
  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        // Restore user data
        String userId = prefs.getString('user_id') ?? '';
        String userName = prefs.getString('user_name') ?? '';
        String userEmail = prefs.getString('user_email') ?? '';
        String userUsername = prefs.getString('user_username') ?? '';

        if (userId.isNotEmpty) {
          _currentUser = User(
            id: userId,
            name: userName,
            email: userEmail,
            username: userUsername,
            password: '', // Don't store password in SharedPreferences
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking login state: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _currentUser = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }
}