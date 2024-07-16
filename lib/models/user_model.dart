import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  String uid;
  String username;
  String email;
  String dateOfBirth;
  String gender;
  GeoPoint geoPoint;
  String profilePicture;
  String firstName;
  String lastName;
  String country;
  String statusMessage;
  int numberOfFollowers;
  List<String> friends;
  Timestamp? memberSince;
  Map<String, dynamic> location;
  Map<String, dynamic> notificationSettings;
  Timestamp? lastActive;
  String nativeLanguage;
  String learningLanguage; // Only one learning language
  String accountType;
  int age;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.geoPoint,
    required this.profilePicture,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.statusMessage,
    required this.numberOfFollowers,
    required this.friends,
    this.memberSince,
    required this.location,
    required this.notificationSettings,
    this.lastActive,
    required this.nativeLanguage,
    required this.learningLanguage,
    required this.accountType,
    required this.age,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? '',
      geoPoint: location['geoPoint'] ?? GeoPoint(0, 0),
      profilePicture: data['profilePicture'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      country: data['country'] ?? '',
      statusMessage: data['statusMessage'] ?? '',
      numberOfFollowers: data['numberOfFollowers'] ?? 0,
      friends: List<String>.from(data['friends'] ?? []),
      memberSince: data['memberSince'],
      location: {
        'city': location['city'] ?? '',
        'country': location['country'] ?? '',
        'latitude': location['latitude'] ?? 0,
        'longitude': location['longitude'] ?? 0,
      },
      notificationSettings: {
        'newFollower': data['notificationSettings']?['newFollower'] ?? true,
        'newMessage': data['notificationSettings']?['newMessage'] ?? true,
      },
      lastActive: data['lastActive'],
      nativeLanguage: data['nativeLanguage'] ?? '',
      learningLanguage: data['learningLanguage'] ?? '',
      accountType: data['accountType'] ?? 'free',
      age: data['dateOfBirth'] != null && data['dateOfBirth'].isNotEmpty
          ? _calculateAge(data['dateOfBirth'])
          : 0, // Default age to 0 if dateOfBirth is not available
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'location': {
        'geoPoint': geoPoint,
        'city': location['city'],
        'country': location['country'],
        'latitude': location['latitude'],
        'longitude': location['longitude'],
      },
      'country': country,
      'profilePicture': profilePicture,
      'firstName': firstName,
      'lastName': lastName,
      'statusMessage': statusMessage,
      'numberOfFollowers': numberOfFollowers,
      'friends': friends,
      'memberSince': memberSince,
      'notificationSettings': notificationSettings,
      'lastActive': lastActive,
      'nativeLanguage': nativeLanguage,
      'learningLanguage': learningLanguage,
      'accountType': accountType,
      'age': age,
    };
  }

  static int _calculateAge(String dateOfBirth) {
    try {
      DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dateOfBirth);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      // Handle invalid date format or other errors
      print('Error parsing date of birth: $e');
      return 0; // Default age to 0 if parsing fails
    }
  }
}
