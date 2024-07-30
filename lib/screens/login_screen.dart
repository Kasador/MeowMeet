import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_step1.dart';
import 'profile_completion_screen.dart';
import '../theme.dart';
import '../widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../generated/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService auth = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.primaryColor),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: _isLoading
            ? Image.asset('assets/loading_gifs/cat-eating.gif') // Show loading GIF
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.login,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations.welcomeBack,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: usernameController,
                        labelText: localizations.username,
                        prefixIcon: Icons.person,
                        inputFormatters: [
                          LowerCaseTextInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.username;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        labelText: localizations.password,
                        prefixIcon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.password;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: localizations.logInButton,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true; // Start loading
                            });
                            try {
                              User? user = await auth.signInWithUsernameAndPassword(
                                usernameController.text,
                                passwordController.text,
                              );
                              if (user != null) {
                                DocumentSnapshot doc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                UserModel userModel = UserModel.fromDocumentSnapshot(doc);

                                if (userModel.gender.isEmpty ||
                                    userModel.dateOfBirth.isEmpty ||
                                    userModel.country.isEmpty) {
                                  // Redirect to profile completion screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileCompletionScreen(
                                            user: userModel,
                                            username: userModel.username)),
                                  );
                                } else {
                                  // Redirect to home screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeScreen()),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false; // Stop loading
                              });
                            }
                          }
                        },
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpStep1()),
                          );
                        },
                        child: Text(
                          localizations.dontHaveAccount,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              indent: 30,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(localizations.or),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              endIndent: 30,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                        ),
                        label: Text(localizations.signInWithGoogle),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Start loading before Google Sign-In
                          });
                          try {
                            User? user = await auth.signInWithGoogle();
                            if (user != null) {
                              DocumentSnapshot doc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();
                              UserModel userModel = UserModel.fromDocumentSnapshot(doc);

                              if (userModel.gender.isEmpty ||
                                  userModel.dateOfBirth.isEmpty ||
                                  userModel.country.isEmpty) {
                                // Redirect to profile completion screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileCompletionScreen(
                                          user: userModel,
                                          username: userModel.username)),
                                );
                              } else {
                                // Redirect to home screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false; // Stop loading
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class LowerCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
