import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meow_meet/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '439712658549-rnukeu8t0sibtpora398llkvffvgbrd1.apps.googleusercontent.com',
  );

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
    String dateOfBirth,
    String gender,
    GeoPoint location,
    String country,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      String deviceLanguage = window.locale.languageCode;

      await _firestore.collection('users').doc(user?.uid).set({
        'username': username.toLowerCase(),
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'location': {
          'geoPoint': location,
        },
        'country': country,
        'allowMessagesFrom': 'Everyone',
        'isProfilePublic': true,
        'languagePreferences': ['English'],
        'lastActive': FieldValue.serverTimestamp(),
        'notificationSettings': {
          'newFollower': true,
          'newMessage': true,
        },
        'numberOfFollowers': 0,
        'profilePicture': '',
        'statusMessage': '',
        'memberSince': FieldValue.serverTimestamp(),
        'nativeLanguage': deviceLanguage, // Add nativeLanguage field
      });

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'The email is already in use by another account.';
        case 'weak-password':
          throw 'The password provided is too weak. Please ensure it has at least 8 characters, including an uppercase letter, a lowercase letter, a number, and a special character.';
        default:
          throw 'An unknown error occurred: ${e.message}. Please try again.';
      }
    } catch (e) {
      print(e.toString());
      throw 'An unknown error occurred: ${e.toString()}. Please try again.';
    }
  }

  Future<User?> signInWithUsernameAndPassword(String username, String password) async {
    try {
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw 'No user found for that username.';
      }

      String email = result.docs.first.get('email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update lastActive
      final User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that username.';
        case 'wrong-password':
          throw 'Wrong password provided.';
        case 'invalid-email':
          throw 'The username is not valid.';
        default:
          throw 'An unknown error occurred: ${e.message}. Please try again.';
      }
    } catch (e) {
      print(e.toString());
      throw 'An unknown error occurred: ${e.toString()}. Please try again.';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In aborted';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Check if user data exists in Firestore, if not, create a new record
      if (user != null) {
        final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          String deviceLanguage = window.locale.languageCode;

          await _firestore.collection('users').doc(user.uid).set({
            'username': user.email!.split('@')[0], // Using email prefix as username
            'email': user.email,
            'firstName': user.displayName?.split(' ')[0] ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'dateOfBirth': '', // Date of birth is not provided by Google, set empty
            'gender': '', // Gender is not provided by Google, set empty
            'location': {
              'city': '',
              'country': '',
              'latitude': 0,
              'longitude': 0,
            },
            'country': '', // Country is not provided by Google, set empty
            'allowMessagesFrom': 'Everyone',
            'isProfilePublic': true,
            'languagePreferences': ['English'],
            'lastActive': FieldValue.serverTimestamp(),
            'notificationSettings': {
              'newFollower': true,
              'newMessage': true,
            },
            'numberOfFollowers': 0,
            'profilePicture': user.photoURL,
            'statusMessage': '',
            'memberSince': FieldValue.serverTimestamp(), // Add memberSince field
            'nativeLanguage': deviceLanguage, // Add nativeLanguage field
          });
        } else {
          // Update the lastActive field for existing users
          await _firestore.collection('users').doc(user.uid).update({
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw 'Account already exists with a different credential.';
        case 'invalid-credential':
          throw 'Invalid credential provided.';
        default:
          throw 'An unknown error occurred: ${e.message}. Please try again.';
      }
    } catch (e) {
      print(e.toString());
      throw 'An unknown error occurred: ${e.toString()}. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      throw 'An unknown error occurred: ${e.toString()}. Please try again.';
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocumentSnapshot(doc);
      } else {
        throw 'User not found.';
      }
    } catch (e) {
      print(e.toString());
      throw 'An unknown error occurred: ${e.toString()}. Please try again.';
    }
  }

  Future<String> translateText(String text, String targetLanguage, String apiKey) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'source': 'en',
        'target': targetLanguage,
        'format': 'text'
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text: ${response.body}');
    }
  }
}
