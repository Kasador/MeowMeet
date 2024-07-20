import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_step1.dart';
import 'login_screen.dart';
import '../theme.dart';
import '../generated/l10n.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _storeDeviceLanguage();
  }

  Future<void> _storeDeviceLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    final deviceLocale = WidgetsBinding.instance.window.locales.first.languageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', deviceLocale);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'nativeLanguage': deviceLocale,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png'), // Ensure you have a logo asset
              const SizedBox(height: 20),
              // Text(
              //   localizations.appName,
              //   style: TextStyle(
              //     fontSize: 48,
              //     fontWeight: FontWeight.bold,
              //     color: AppTheme.primaryColor,
              //   ),
              // ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  localizations.slogan,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup_step1');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // Updated to use primaryColor from the custom theme
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  localizations.createAccount,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to LoginScreen
                },
                child: Text(
                  localizations.signIn,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
