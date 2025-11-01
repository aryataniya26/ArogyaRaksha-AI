import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  UserModel? _currentUser;
  User? _firebaseUser;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthViewModel() {
    _initAuthListener();
  }

  // Listen to auth state changes
  void _initAuthListener() {
    _authRepository.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      _currentUser = await _authRepository.getUserData();
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // Check if first time user
  Future<bool> isFirstTimeUser() async {
    return await _authRepository.isFirstTimeUser();
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signIn(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signInWithGoogle();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authRepository.signOut();

      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _firebaseUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.resetPassword(email);

      _status = AuthStatus.initial;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authRepository.deleteAccount();

      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _firebaseUser = null;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _authRepository.updateUserData(data);
      await _loadUserData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




// // auth_viewmodel.dart
// import 'package:flutter/material.dart';
// import '../../data/repositories/auth_repository.dart';
// import '../../data/models/user_model.dart';
//
// class AuthViewModel extends ChangeNotifier {
//   final AuthRepository _repository = AuthRepository();
//
//   UserModel? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   UserModel? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isAuthenticated => _currentUser != null;
//
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       _currentUser = await _repository.login(email, password);
//       _isLoading = false;
//       notifyListeners();
//       return _currentUser != null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//
//   Future<bool> signup(String email, String password, Map<String, dynamic> userData) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       _currentUser = await _repository.signup(email, password, userData);
//       _isLoading = false;
//       notifyListeners();
//       return _currentUser != null;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//
//   Future<void> logout() async {
//     await _repository.logout();
//     _currentUser = null;
//     notifyListeners();
//   }
// }
//
//
//
//
