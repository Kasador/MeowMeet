import 'package:flutter/material.dart';
import 'package:meow_meet/theme.dart';
import 'package:meow_meet/widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../generated/l10n.dart';

class SignUpStep1 extends StatefulWidget {
  const SignUpStep1({super.key});

  @override
  _SignUpStep1State createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isUsernameAvailable = false;
  bool isUsernameChecked = false;
  bool isUsernameValid = true;
  final _profanityFilter = ProfanityFilter();
  Timer? _debounce;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    _debounce?.cancel();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  localizations.createAccount,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: firstNameController,
                        labelText: localizations.firstName,
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.firstName;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: lastNameController,
                        labelText: localizations.lastName,
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.lastName;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
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
                      return localizations.invalidUsername;
                    }
                    if (_profanityFilter.hasProfanity(value)) {
                      return localizations.invalidUsername;
                    }
                    if (_hasTripleRepeats(value)) {
                      return localizations.invalidUsername;
                    }
                    if (!isUsernameAvailable) {
                      return localizations.usernameTaken;
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
                CustomTextField(
                  controller: emailController,
                  labelText: localizations.email,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.email;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: AppTheme.primaryColor),
                      Icon(Icons.circle, color: Colors.grey),
                      Icon(Icons.circle, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    text: localizations.continueButton,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(
                          context,
                          '/signup_step2',
                          arguments: {
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                            'username': usernameController.text,
                            'email': emailController.text,
                          },
                        );
                      }
                    },
                    backgroundColor: AppTheme.primaryColor,
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

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
