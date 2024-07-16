import 'dart:async'; // For Timer
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../theme.dart';
import '../widgets/custom_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:flag/flag.dart';
import 'package:flutter/services.dart';
import 'package:profanity_filter/profanity_filter.dart'; // For ProfanityFilter
import '../generated/l10n.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final UserModel user;
  final String username;

  const ProfileCompletionScreen({Key? key, required this.user, required this.username}) : super(key: key);

  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  Country? selectedCountry;
  final _formKey = GlobalKey<FormState>();

  bool isProfileComplete = false; // Indicator for profile completion
  bool isUsernameAvailable = false;
  bool isUsernameChecked = false;
  bool isUsernameValid = false; // Assuming it's valid by default
  Timer? _debounce;
  final ProfanityFilter _profanityFilter = ProfanityFilter();

  @override
  void initState() {
    super.initState();
    dateOfBirthController.text = widget.user.dateOfBirth;
    genderController.text = widget.user.gender;
    usernameController.text = widget.username; // Set initial value from SignUpStep1
    // Set the initial selected country from user data if available
    if (widget.user.country.isNotEmpty) {
      selectedCountry = Country(
        countryCode: _getCountryCode(widget.user.country), // Set the country code correctly
        name: widget.user.country,
        phoneCode: '1', // Placeholder for phone code
        e164Sc: 1, // Placeholder for e164Sc, now using int
        geographic: true, // Placeholder for geographic
        level: 1, // Placeholder for level
        example: '1234567890', // Placeholder for example phone number
        displayName: widget.user.country, // Using country name as display name
        displayNameNoCountryCode: widget.user.country, // Using country name as display name without country code
        e164Key: '1', // Placeholder for e164Key, now using String
      );
    }
    // Check if profile is complete
    isProfileComplete = _isProfileComplete();
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    genderController.dispose();
    usernameController.dispose(); // Dispose controller
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
          'gender': genderController.text,
          'dateOfBirth': dateOfBirthController.text,
          'country': selectedCountry?.name ?? '',
          'username': usernameController.text.toLowerCase(), // Update username to Firestore
          'nativeLanguage': _getNativeLanguage(selectedCountry?.name ?? ''),
          'age': _calculateAge(dateOfBirthController.text),
        });

        // Update profile completion status
        setState(() {
          isProfileComplete = _isProfileComplete();
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  bool _isProfileComplete() {
    // Check if all required fields are filled
    return widget.user.gender.isNotEmpty &&
        widget.user.dateOfBirth.isNotEmpty &&
        widget.user.country.isNotEmpty &&
        widget.username.isNotEmpty; // Add more conditions if needed
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime(DateTime.now().year - 18),
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime date) {
                    setState(() {
                      dateOfBirthController.text = "${date.toLocal()}".split(' ')[0];
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('Done', style: TextStyle(color: AppTheme.primaryColor)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logoutAndDeleteIncompleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onUsernameChanged(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(username);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || !RegExp(r'^[a-z0-9]{1,36}$').hasMatch(username) || _profanityFilter.hasProfanity(username) || _hasTripleRepeats(username)) {
      setState(() {
        isUsernameAvailable = false;
        isUsernameChecked = true;
        isUsernameValid = false;
      });
      return;
    }
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();
    setState(() {
      isUsernameAvailable = result.docs.isEmpty;
      isUsernameChecked = true;
      isUsernameValid = true;
    });
  }

  bool _hasTripleRepeats(String input) {
    return RegExp(r'(.)\1{2,}').hasMatch(input);
  }

  String _getNativeLanguage(String countryName) {
    // Map of countries to their native languages
    const countryToLanguage = {
      'United States': 'English',
      'Spain': 'Spanish',
      // Add more countries and their native languages as needed
    };
    return countryToLanguage[countryName] ?? 'Unknown';
  }

  int _calculateAge(String dateOfBirth) {
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
      print('Error parsing date of birth: $e');
      return 0;
    }
  }

  String _getCountryCode(String countryName) {
    final country = Country.tryParse(countryName);
    return country?.countryCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return WillPopScope(
      onWillPop: () async {
        await _logoutAndDeleteIncompleteProfile();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () async {
              await _logoutAndDeleteIncompleteProfile();
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    localizations.completeProfile,
                    style: AppTheme.lightTheme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: dateOfBirthController,
                    labelText: localizations.dateOfBirth,
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.dateOfBirth;
                      }
                      DateTime dob = DateTime.parse(value);
                      if (!_isValidDateOfBirth(dob)) {
                        return 'You must be at least 18 years old';
                      }
                      return null;
                    },
                  ),
                  _buildCountryPicker(localizations),
                  _buildGenderSelection(localizations),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: usernameController,
                    labelText: localizations.username,
                    prefixIcon: Icons.person,
                    suffixIcon: isUsernameChecked
                        ? Icon(
                            isUsernameAvailable && isUsernameValid ? Icons.check : Icons.close,
                            color: isUsernameAvailable && isUsernameValid ? Colors.green : Colors.red,
                          )
                        : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.username;
                      }
                      if (!RegExp(r'^[a-z0-9]{1,36}$').hasMatch(value)) {
                        return 'Invalid username';
                      }
                      if (_profanityFilter.hasProfanity(value)) {
                        return 'Please enter a valid username';
                      }
                      if (_hasTripleRepeats(value)) {
                        return 'Usernames cannot have more than two repeated characters';
                      }
                      if (!isUsernameAvailable) {
                        return 'Username is taken';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        isUsernameChecked = false;
                      });
                      _onUsernameChanged(value);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]')),
                      LowerCaseTextFormatter(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      text: localizations.saveProfile,
                      onPressed: _saveProfile,
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidDateOfBirth(DateTime input) {
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(today.year - 18, today.month, today.day);
    return input.isBefore(adultDate);
  }

  Widget _buildCountryPicker(S localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.nationality,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country;
                });
              },
              countryListTheme: CountryListThemeData(
                inputDecoration: InputDecoration(
                  hintText: 'Start typing to search',
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                if (selectedCountry != null) ...[
                  CountryFlagWidget(countryCode: selectedCountry!.countryCode),
                  const SizedBox(width: 10),
                ],
                Text(
                  selectedCountry == null ? localizations.nationality : selectedCountry!.name,
                  style: TextStyle(
                    color: selectedCountry == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGenderSelection(S localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.gender,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  genderController.text = 'Male';
                });
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/male.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Male',
                    style: TextStyle(
                      color: genderController.text == 'Male' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: genderController.text == 'Male' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  genderController.text = 'Female';
                });
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/female.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Female',
                    style: TextStyle(
                      color: genderController.text == 'Female' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: genderController.text == 'Female' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  genderController.text = 'Other';
                });
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/other.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Other',
                    style: TextStyle(
                      color: genderController.text == 'Other' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: genderController.text == 'Other' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CountryFlagWidget extends StatelessWidget {
  final String countryCode;

  const CountryFlagWidget({Key? key, required this.countryCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flag.fromString(
      countryCode,
      width: 24,
      height: 24,
      fit: BoxFit.fill,
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
