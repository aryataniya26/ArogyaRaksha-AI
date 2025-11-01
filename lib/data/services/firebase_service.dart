import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email & Password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _createUserDocument(
        uid: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
      );

      print('User signed up successfully: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during sign up: $e');
      throw 'An unexpected error occurred';
    }
  }

  // Sign In with Email & Password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in successfully: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw 'An unexpected error occurred';
    }
  }

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        print('Google sign in cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Create user document if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'User',
          phone: userCredential.user!.phoneNumber ?? '',
        );
      }

      print('Google sign in successful: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error during Google sign in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      print('Platform exception during Google sign in: ${e.code} - ${e.message}');
      throw 'Google Sign-In failed: ${e.message}';
    } catch (e) {
      print('Unexpected error during Google sign in: $e');
      throw 'Google sign in failed. Please try again.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw 'Failed to sign out';
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete Firestore document
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete auth account
        await user.delete();
        print('Account deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      print('Delete account error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Create User Document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    required String phone,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'bloodGroup': '',
        'age': 0,
        'address': '',
        'medicalHistory': {
          'allergies': '',
        },
        'insurance': {
          'provider': '',
          'policyId': '',
        },
        'insuranceDetails': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      print('User document created in Firestore');
    } catch (e) {
      print('Error creating user document: $e');
      throw 'Failed to create user profile';
    }
  }

  // Get User Data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Update User Data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
      throw 'Failed to update profile';
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class FirebaseService {
//   static final FirebaseService _instance = FirebaseService._internal();
//   factory FirebaseService() => _instance;
//   FirebaseService._internal();
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   // Get current user
//   User? get currentUser => _auth.currentUser;
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   // Sign Up with Email & Password
//   Future<UserCredential?> signUpWithEmail({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Update display name
//       await credential.user?.updateDisplayName(name);
//
//       // Create user document in Firestore
//       await _createUserDocument(
//         uid: credential.user!.uid,
//         email: email,
//         name: name,
//         phone: phone,
//       );
//
//       print('User signed up successfully: ${credential.user?.email}');
//       return credential;
//     } on FirebaseAuthException catch (e) {
//       print('Sign up error: ${e.message}');
//       throw _handleAuthException(e);
//     } catch (e) {
//       print('Unexpected error during sign up: $e');
//       throw 'An unexpected error occurred';
//     }
//   }
//
//   // Sign In with Email & Password
//   Future<UserCredential?> signInWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print('User signed in successfully: ${credential.user?.email}');
//       return credential;
//     } on FirebaseAuthException catch (e) {
//       print('Sign in error: ${e.message}');
//       throw _handleAuthException(e);
//     } catch (e) {
//       print('Unexpected error during sign in: $e');
//       throw 'An unexpected error occurred';
//     }
//   }
//
//   // Sign In with Google
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//
//       // Create user document if new user
//       if (userCredential.additionalUserInfo?.isNewUser ?? false) {
//         await _createUserDocument(
//           uid: userCredential.user!.uid,
//           email: userCredential.user!.email!,
//           name: userCredential.user!.displayName ?? 'User',
//           phone: userCredential.user!.phoneNumber ?? '',
//         );
//       }
//
//       print('Google sign in successful: ${userCredential.user?.email}');
//       return userCredential;
//     } catch (e) {
//       print('Google sign in error: $e');
//       throw 'Google sign in failed';
//     }
//   }
//
//   // Sign Out
//   Future<void> signOut() async {
//     try {
//       await Future.wait([
//         _auth.signOut(),
//         _googleSignIn.signOut(),
//       ]);
//       print('User signed out successfully');
//     } catch (e) {
//       print('Sign out error: $e');
//       throw 'Failed to sign out';
//     }
//   }
//
//   // Reset Password
//   Future<void> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       print('Password reset email sent to: $email');
//     } on FirebaseAuthException catch (e) {
//       print('Password reset error: ${e.message}');
//       throw _handleAuthException(e);
//     }
//   }
//
//   // Delete Account
//   Future<void> deleteAccount() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         // Delete Firestore document
//         await _firestore.collection('users').doc(user.uid).delete();
//
//         // Delete auth account
//         await user.delete();
//         print('Account deleted successfully');
//       }
//     } on FirebaseAuthException catch (e) {
//       print('Delete account error: ${e.message}');
//       throw _handleAuthException(e);
//     }
//   }
//
//   // Create User Document in Firestore
//   Future<void> _createUserDocument({
//     required String uid,
//     required String email,
//     required String name,
//     required String phone,
//   }) async {
//     try {
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': email,
//         'name': name,
//         'phone': phone,
//         'bloodGroup': '',
//         'age': 0,
//         'address': '',
//         'medicalHistory': {
//           'allergies': '',
//         },
//         'insurance': {
//           'provider': '',
//           'policyId': '',
//         },
//         'insuranceDetails': {},
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         'isActive': true,
//       });
//       print('User document created in Firestore');
//     } catch (e) {
//       print('Error creating user document: $e');
//       throw 'Failed to create user profile';
//     }
//   }
//
//   // Get User Data from Firestore
//   Future<Map<String, dynamic>?> getUserData(String uid) async {
//     try {
//       DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
//       return doc.data() as Map<String, dynamic>?;
//     } catch (e) {
//       print('Error fetching user data: $e');
//       return null;
//     }
//   }
//
//   // Update User Data
//   Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
//     try {
//       await _firestore.collection('users').doc(uid).update({
//         ...data,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       print('User data updated successfully');
//     } catch (e) {
//       print('Error updating user data: $e');
//       throw 'Failed to update profile';
//     }
//   }
//
//   // Handle Firebase Auth Exceptions
//   String _handleAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'email-already-in-use':
//         return 'This email is already registered';
//       case 'invalid-email':
//         return 'Invalid email address';
//       case 'weak-password':
//         return 'Password should be at least 6 characters';
//       case 'user-not-found':
//         return 'No user found with this email';
//       case 'wrong-password':
//         return 'Wrong password provided';
//       case 'user-disabled':
//         return 'This account has been disabled';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later';
//       case 'operation-not-allowed':
//         return 'Operation not allowed';
//       case 'requires-recent-login':
//         return 'Please log in again to perform this action';
//       default:
//         return e.message ?? 'An error occurred';
//     }
//   }
// }
//
//
//
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'dart:io';
// //
// // class FirebaseService {
// //   static final FirebaseAuth _auth = FirebaseAuth.instance;
// //   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   static final FirebaseStorage _storage = FirebaseStorage.instance;
// //
// //   // Auth Methods
// //   static Future<UserCredential?> signInWithEmail(
// //       String email,
// //       String password,
// //       ) async {
// //     try {
// //       return await _auth.signInWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //     } catch (e) {
// //       print('Sign in error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<UserCredential?> signUpWithEmail(
// //       String email,
// //       String password,
// //       ) async {
// //     try {
// //       return await _auth.createUserWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //     } catch (e) {
// //       print('Sign up error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<void> signOut() async {
// //     try {
// //       await _auth.signOut();
// //     } catch (e) {
// //       print('Sign out error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<void> resetPassword(String email) async {
// //     try {
// //       await _auth.sendPasswordResetEmail(email: email);
// //     } catch (e) {
// //       print('Reset password error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static User? getCurrentUser() {
// //     return _auth.currentUser;
// //   }
// //
// //   static String? getCurrentUserId() {
// //     return _auth.currentUser?.uid;
// //   }
// //
// //   // Firestore Methods
// //   static Future<void> createDocument(
// //       String collection,
// //       String documentId,
// //       Map<String, dynamic> data,
// //       ) async {
// //     try {
// //       await _firestore.collection(collection).doc(documentId).set(data);
// //     } catch (e) {
// //       print('Create document error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<DocumentSnapshot> getDocument(
// //       String collection,
// //       String documentId,
// //       ) async {
// //     try {
// //       return await _firestore.collection(collection).doc(documentId).get();
// //     } catch (e) {
// //       print('Get document error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<void> updateDocument(
// //       String collection,
// //       String documentId,
// //       Map<String, dynamic> data,
// //       ) async {
// //     try {
// //       await _firestore.collection(collection).doc(documentId).update(data);
// //     } catch (e) {
// //       print('Update document error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<void> deleteDocument(
// //       String collection,
// //       String documentId,
// //       ) async {
// //     try {
// //       await _firestore.collection(collection).doc(documentId).delete();
// //     } catch (e) {
// //       print('Delete document error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<QuerySnapshot> getCollection(String collection) async {
// //     try {
// //       return await _firestore.collection(collection).get();
// //     } catch (e) {
// //       print('Get collection error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Stream<DocumentSnapshot> streamDocument(
// //       String collection,
// //       String documentId,
// //       ) {
// //     return _firestore.collection(collection).doc(documentId).snapshots();
// //   }
// //
// //   static Stream<QuerySnapshot> streamCollection(String collection) {
// //     return _firestore.collection(collection).snapshots();
// //   }
// //
// //   // Storage Methods
// //   static Future<String?> uploadFile(File file, String path) async {
// //     try {
// //       final ref = _storage.ref().child(path);
// //       final uploadTask = await ref.putFile(file);
// //       return await uploadTask.ref.getDownloadURL();
// //     } catch (e) {
// //       print('Upload file error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   static Future<void> deleteFile(String path) async {
// //     try {
// //       final ref = _storage.ref().child(path);
// //       await ref.delete();
// //     } catch (e) {
// //       print('Delete file error: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // Collections
// //   static const String usersCollection = 'users';
// //   static const String emergenciesCollection = 'emergencies';
// //   static const String vitalsCollection = 'vitals';
// //   static const String ambulancesCollection = 'ambulances';
// //   static const String hospitalsCollection = 'hospitals';
// //   static const String notificationsCollection = 'notifications';
// // }