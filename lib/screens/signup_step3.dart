import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meow_meet/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:meow_meet/services/auth_service.dart';
import 'package:meow_meet/widgets/custom_widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flag/flag.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'dart:async';
import '../generated/l10n.dart';

class SignUpStep3 extends StatefulWidget {
  const SignUpStep3({super.key});

  @override
  _SignUpStep3State createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  final TextEditingController dateOfBirthController = TextEditingController();
  Country? selectedCountry;
  Position? _currentPosition;
  final _profanityFilter = ProfanityFilter();
  final _formKey = GlobalKey<FormState>();
  String gender = 'Male'; // Default to male for simplicity

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationError('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationError('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationError('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _setCountryFromLocation(position);
    } catch (e) {
      _showLocationError('Failed to get location: $e');
    }
  }

  void _setCountryFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          selectedCountry = Country(
            countryCode: placemark.isoCountryCode!,
            name: placemark.country!,
            phoneCode: '1', // Placeholder for phone code
            e164Sc: 1, // Placeholder for e164Sc, now using int
            geographic: true, // Placeholder for geographic
            level: 1, // Placeholder for level
            example: '1234567890', // Placeholder for example phone number
            displayName: placemark.country!, // Using country name as display name
            displayNameNoCountryCode: placemark.country!, // Using country name as display name without country code
            e164Key: '1', // Placeholder for e164Key, now using String
          );
        });
      }
    } catch (e) {
      _showLocationError('Failed to get country from location: $e');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidDateOfBirth(DateTime input) {
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(today.year - 18, today.month, today.day);
    return input.isBefore(adultDate);
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

  @override
  void dispose() {
    dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () {
            Navigator.pop(context);
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
                      return localizations.ageRestriction;
                    }
                    return null;
                  },
                ),
                _buildCountryPicker(localizations),
                _buildGenderSelection(localizations),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: AppTheme.primaryColor),
                      Icon(Icons.circle, color: AppTheme.primaryColor),
                      Icon(Icons.circle, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    text: localizations.createAccount,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          User? user = await AuthService().registerWithEmailAndPassword(
                            args['email']!,
                            args['password']!,
                            args['username']!,
                            args['firstName']!,
                            args['lastName']!,
                            dateOfBirthController.text,
                            gender,
                            GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
                            selectedCountry!.name, // Pass the country name
                          );
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: Text(
                      localizations.signIn,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  gender = 'Male';
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
                    localizations.male,
                    style: TextStyle(
                      color: gender == 'Male' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: gender == 'Male' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  gender = 'Female';
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
                    localizations.female,
                    style: TextStyle(
                      color: gender == 'Female' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: gender == 'Female' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  gender = 'Other';
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
                    localizations.other,
                    style: TextStyle(
                      color: gender == 'Other' ? AppTheme.primaryColor : Colors.black54,
                      fontWeight: gender == 'Other' ? FontWeight.bold : FontWeight.normal,
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
