import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../theme.dart';
import 'settings_screen.dart';
import 'package:flag/flag.dart';
import '../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController statusController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isEditingStatus = false;
  String _message = '';
  bool _isOnline = false;

  final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  DatabaseReference? _statusRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _statusRef = FirebaseDatabase.instance.ref('users/${user.uid}/status');
      _statusSubscription = _statusRef?.onValue.listen((event) {
        final status = event.snapshot.value as String?;
        setState(() {
          _isOnline = status == 'online';
        });
      });
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        await _checkForNudity(imageFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _checkForNudity(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final imageBytes = imageFile.readAsBytesSync();
      final base64Image = base64Encode(imageBytes);

      final body = jsonEncode({
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'SAFE_SEARCH_DETECTION',
                'maxResults': 1
              }
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final safeSearch = jsonResponse['responses'][0]['safeSearchAnnotation'];

        final adult = safeSearch['adult'];
        final violence = safeSearch['violence'];
        final racy = safeSearch['racy'];

        if (adult == 'LIKELY' || adult == 'VERY_LIKELY' || 
            violence == 'LIKELY' || violence == 'VERY_LIKELY' ||
            racy == 'VERY_LIKELY') {
          setState(() {
            _message = S.of(context).errorMessage;
            _isUploading = false;
          });
        } else {
          final File? croppedFile = await _cropImage(imageFile);
          if (croppedFile != null) {
            await _uploadImage(croppedFile);
          }
        }
      } else {
        print('Error with the Google Vision API: ${response.statusCode}');
        _showSnackBar(S.of(context).errorProcessingImage);
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('Error with the Google Vision API: $e');
      _showSnackBar(S.of(context).errorProcessingImage);
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio7x5,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio7x5,
          ],
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _uploadImage(File image) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user?.uid}.jpg');
      final uploadTask = storageRef.putFile(image);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'profilePicture': url,
      });

      setState(() {
        _isUploading = false;
        _message = S.of(context).imageUploadedSuccessfully;
      });

      print('Uploaded Image URL: $url');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error uploading image: $e');
      _showSnackBar(S.of(context).errorUploadingImage);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context);
    final User? user = FirebaseAuth.instance.currentUser;
    final localizations = S.of(context);

    return DefaultTabController(
      length: 2,
      child: FutureBuilder<UserModel?>(
        future: user != null ? auth.getUserData(user.uid) : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          } else {
            UserModel userData = snapshot.data!;

            String memberSinceFormatted = '';
            if (userData.memberSince != null) {
              final DateTime memberSinceDate = userData.memberSince!.toDate();
              memberSinceFormatted = DateFormat('yyyy').format(memberSinceDate);
            }

            return Scaffold(
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: AppTheme.primaryColor,
                title: Text(
                  '@${userData.username}',
                  style: TextStyle(color: AppTheme.backgroundColor),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: AppTheme.backgroundColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: userData.profilePicture.isNotEmpty 
                                  ? NetworkImage(userData.profilePicture)
                                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.backgroundColor),
                                  onPressed: _isUploading ? null : _pickImage,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Flag.fromString(
                                      _getCountryCode(userData.country),
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              if (userData.accountType == 'premium')
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 13.5,
                                    backgroundColor: AppTheme.backgroundColor,
                                    child: Icon(
                                      Icons.workspace_premium,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: _isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isOnline
                                        ? localizations.online
                                        : localizations.offline,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (userData.gender == 'Male')
                                    Icon(Icons.male, color: Colors.blue)
                                  else if (userData.gender == 'Female')
                                    Icon(Icons.female, color: Colors.pinkAccent)
                                  else if (userData.gender == 'Other')
                                    Icon(Icons.transgender, color: Colors.purple),
                                  Text(
                                    '${userData.age}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          if (_isUploading)
                            const CircularProgressIndicator(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _isEditingStatus
                                  ? TextField(
                                      controller: statusController..text = userData.statusMessage,
                                      onSubmitted: (value) {
                                        _updateStatus(userData, value);
                                      },
                                      decoration: InputDecoration(
                                        hintText: localizations.statusMessageHint,
                                        border: InputBorder.none,
                                      ),
                                    )
                                  : Text(
                                      userData.statusMessage.isNotEmpty ? userData.statusMessage : localizations.statusMessageHint,
                                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(_isEditingStatus ? Icons.check : Icons.edit, color: AppTheme.primaryColor),
                            onPressed: () {
                              setState(() {
                                if (_isEditingStatus) {
                                  _updateStatus(userData, statusController.text);
                                }
                                _isEditingStatus = !_isEditingStatus;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(localizations.followers, userData.numberOfFollowers.toString(), Icons.people),
                          _buildStatCard(localizations.friends, userData.friends.length.toString(), Icons.person_add),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ButtonsTabBar(
                          backgroundColor: AppTheme.backgroundColor,
                          unselectedBackgroundColor: AppTheme.backgroundColor,
                          unselectedLabelStyle: TextStyle(color: AppTheme.secondaryColor.withAlpha(100)),
                          labelStyle: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(
                              icon: Icon(Icons.person),
                              text: localizations.profile,
                            ),
                            Tab(
                              icon: Icon(Icons.photo_library),
                              text: localizations.moments,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 400,
                        child: TabBarView(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  '${localizations.name}: ${userData.firstName} ${userData.lastName}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.email}: ${userData.email}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.country}: ${userData.country}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.nativeLanguage}: ${userData.nativeLanguage}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.learningLanguage}: ${userData.learningLanguage}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.dateOfBirth}: ${userData.dateOfBirth}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.gender}: ${userData.gender}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${localizations.joinedIn}: $memberSinceFormatted',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'Account Type: ${userData.accountType}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                if (_message.isNotEmpty)
                                  Text(
                                    _message,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            Center(child: Text(localizations.momentsContent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      height: 100,
      width: 130,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 30),
          const SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 20),
          ),
          Text(
            title,
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _updateStatus(UserModel userData, String newStatus) {
    setState(() {
      userData.statusMessage = newStatus;
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(userData.uid)
        .update({'statusMessage': newStatus});
  }

  String _getCountryCode(String countryName) {
    try {
      final country = Country.tryParse(countryName);
      return country?.countryCode ?? ''; // Return country code or empty string if not found
    } catch (e) {
      return ''; // Return empty string if no match found
    }
  }
}
