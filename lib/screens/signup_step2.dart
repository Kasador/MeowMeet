import 'package:flutter/material.dart';
import 'package:meow_meet/theme.dart';
import 'package:meow_meet/widgets/custom_widgets.dart';
import '../generated/l10n.dart';

class SignUpStep2 extends StatefulWidget {
  const SignUpStep2({super.key});

  @override
  _SignUpStep2State createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  localizations.setPassword,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: passwordController,
                  labelText: localizations.password,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.password;
                    }
                    if (value.length < 8) {
                      return localizations.passwordLength;
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: confirmPasswordController,
                  labelText: localizations.confirmPassword,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.confirmPassword;
                    }
                    if (value != passwordController.text) {
                      return localizations.passwordMatch;
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
                      Icon(Icons.circle, color: AppTheme.primaryColor),
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
                          '/signup_step3',
                          arguments: {
                            ...args,
                            'password': passwordController.text,
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
