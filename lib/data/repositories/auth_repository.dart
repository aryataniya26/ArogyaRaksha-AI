import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      final user = _firebaseService.currentUser;
      return !isFirstTime && user != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // ✅ Check if first time user
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isFirstTime') ?? true;
    } catch (e) {
      print('Error checking first time user: $e');
      return true;
    }
  }

  // ✅ Set first time flag
  Future<void> setFirstTimeFalse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
    } catch (e) {
      print('Error setting first time flag: $e');
    }
  }

  // ✅ Get current user
  User? getCurrentUser() {
    return _firebaseService.currentUser;
  }

  // ✅ Auth state stream
  Stream<User?> authStateChanges() {
    return _firebaseService.authStateChanges;
  }

  // ✅ Sign up (With Firestore profile creation)
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _firebaseService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (credential != null) {
        final user = credential.user;
        if (user != null) {
          // 🟢 Create initial user profile in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': name,
            'phone': phone,
            'address': '',
            'bloodGroup': '',
            'gender': '',
            'age': '',
            'profilePic': '',
            'medicalInfo': {
              'allergies': [],
              'conditions': [],
              'medications': [],
              'chronicDiseases': [],
              'disabilities': '',
            },
            'emergencyContacts': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await setFirstTimeFalse();
      }

      return credential;
    } catch (e) {
      print('Sign up error in repository: $e');
      rethrow;
    }
  }

  // ✅ Sign in
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential != null) {
        await setFirstTimeFalse();
      }

      return credential;
    } catch (e) {
      print('Sign in error in repository: $e');
      rethrow;
    }
  }

  // ✅ Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final credential = await _firebaseService.signInWithGoogle();

      if (credential != null) {
        final user = credential.user;

        // 🟢 Check if user profile exists, if not — create one
        final docRef = _firestore.collection('users').doc(user!.uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? '',
            'phone': user.phoneNumber ?? '',
            'address': '',
            'bloodGroup': '',
            'gender': '',
            'age': '',
            'profilePic': user.photoURL ?? '',
            'medicalInfo': {
              'allergies': [],
              'conditions': [],
              'medications': [],
              'chronicDiseases': [],
              'disabilities': '',
            },
            'emergencyContacts': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await setFirstTimeFalse();
      }

      return credential;
    } catch (e) {
      print('Google sign in error in repository: $e');
      rethrow;
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      print('Sign out error in repository: $e');
      rethrow;
    }
  }

  // ✅ Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      print('Reset password error in repository: $e');
      rethrow;
    }
  }

  // ✅ Delete account
  Future<void> deleteAccount() async {
    try {
      await _firebaseService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', true);
    } catch (e) {
      print('Delete account error in repository: $e');
      rethrow;
    }
  }

  // ✅ Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return null;

      final doc =
      await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print('Get user data error in repository: $e');
      return null;
    }
  }

  // ✅ Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) throw 'No user logged in';

      await _firestore.collection('users').doc(user.uid).update(data);
    } catch (e) {
      print('Update user data error in repository: $e');
      rethrow;
    }
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/firebase_service.dart';
// import '../models/user_model.dart';
//
// class AuthRepository {
//   final FirebaseService _firebaseService = FirebaseService();
//
//   // Check if user is logged in
//   Future<bool> isLoggedIn() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final isFirstTime = prefs.getBool('isFirstTime') ?? true;
//       final user = _firebaseService.currentUser;
//
//       return !isFirstTime && user != null;
//     } catch (e) {
//       print('Error checking login status: $e');
//       return false;
//     }
//   }
//
//   // Check if first time user
//   Future<bool> isFirstTimeUser() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getBool('isFirstTime') ?? true;
//     } catch (e) {
//       print('Error checking first time user: $e');
//       return true;
//     }
//   }
//
//   // Set first time flag
//   Future<void> setFirstTimeFalse() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isFirstTime', false);
//     } catch (e) {
//       print('Error setting first time flag: $e');
//     }
//   }
//
//   // Get current user
//   User? getCurrentUser() {
//     return _firebaseService.currentUser;
//   }
//
//   // Auth state stream
//   Stream<User?> authStateChanges() {
//     return _firebaseService.authStateChanges;
//   }
//
//   // Sign up
//   Future<UserCredential?> signUp({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       final credential = await _firebaseService.signUpWithEmail(
//         email: email,
//         password: password,
//         name: name,
//         phone: phone,
//       );
//
//       if (credential != null) {
//         await setFirstTimeFalse();
//       }
//
//       return credential;
//     } catch (e) {
//       print('Sign up error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Sign in
//   Future<UserCredential?> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credential = await _firebaseService.signInWithEmail(
//         email: email,
//         password: password,
//       );
//
//       if (credential != null) {
//         await setFirstTimeFalse();
//       }
//
//       return credential;
//     } catch (e) {
//       print('Sign in error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Google sign in
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final credential = await _firebaseService.signInWithGoogle();
//
//       if (credential != null) {
//         await setFirstTimeFalse();
//       }
//
//       return credential;
//     } catch (e) {
//       print('Google sign in error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await _firebaseService.signOut();
//       // Note: Don't reset isFirstTime on logout
//     } catch (e) {
//       print('Sign out error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Reset password
//   Future<void> resetPassword(String email) async {
//     try {
//       await _firebaseService.resetPassword(email);
//     } catch (e) {
//       print('Reset password error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Delete account
//   Future<void> deleteAccount() async {
//     try {
//       await _firebaseService.deleteAccount();
//
//       // Reset first time flag when account is deleted
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isFirstTime', true);
//     } catch (e) {
//       print('Delete account error in repository: $e');
//       rethrow;
//     }
//   }
//
//   // Get user data
//   Future<UserModel?> getUserData() async {
//     try {
//       final user = _firebaseService.currentUser;
//       if (user == null) return null;
//
//       final data = await _firebaseService.getUserData(user.uid);
//       if (data == null) return null;
//
//       return UserModel.fromJson(data);
//     } catch (e) {
//       print('Get user data error in repository: $e');
//       return null;
//     }
//   }
//
//   // Update user data
//   Future<void> updateUserData(Map<String, dynamic> data) async {
//     try {
//       final user = _firebaseService.currentUser;
//       if (user == null) throw 'No user logged in';
//
//       await _firebaseService.updateUserData(user.uid, data);
//     } catch (e) {
//       print('Update user data error in repository: $e');
//       rethrow;
//     }
//   }
// }
//
//
