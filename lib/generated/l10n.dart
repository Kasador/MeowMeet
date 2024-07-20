// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // /// `MeowMeet`
  // String get appName {
  //   return Intl.message(
  //     'MeowMeet',
  //     name: 'appName',
  //     desc: 'The name of the application',
  //     args: [],
  //   );
  // }

  /// `Connect, share, and discover moments with friends worldwide.`
  String get slogan {
    return Intl.message(
      'Connect, share, and discover moments with friends worldwide.',
      name: 'slogan',
      desc: 'The slogan of the application',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: 'Button text for creating an account',
      args: [],
    );
  }

  /// `Already have an account? Sign In`
  String get signIn {
    return Intl.message(
      'Already have an account? Sign In',
      name: 'signIn',
      desc: 'Button text for signing in',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: 'Login text',
      args: [],
    );
  }

  /// `Hello, welcome back!`
  String get welcomeBack {
    return Intl.message(
      'Hello, welcome back!',
      name: 'welcomeBack',
      desc: 'Welcome back text',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: 'Username field label',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Password field label',
      args: [],
    );
  }

  /// `Log In`
  String get logInButton {
    return Intl.message(
      'Log In',
      name: 'logInButton',
      desc: 'Log in button text',
      args: [],
    );
  }

  /// `Don't have an account? Sign Up`
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account? Sign Up',
      name: 'dontHaveAccount',
      desc: 'Text for sign-up suggestion',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: 'Sign in with Google button text',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: 'Or text',
      args: [],
    );
  }

  /// `Feed`
  String get feed {
    return Intl.message(
      'Feed',
      name: 'feed',
      desc: 'Feed tab label',
      args: [],
    );
  }

  /// `Random Chat`
  String get randomChat {
    return Intl.message(
      'Random Chat',
      name: 'randomChat',
      desc: 'Random Chat tab label',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: 'Chat tab label',
      args: [],
    );
  }

  /// `Map`
  String get map {
    return Intl.message(
      'Map',
      name: 'map',
      desc: 'Map tab label',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Profile tab label',
      args: [],
    );
  }

  /// `Complete your profile`
  String get completeProfile {
    return Intl.message(
      'Complete your profile',
      name: 'completeProfile',
      desc: 'Complete profile text',
      args: [],
    );
  }

  /// `Date of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirth',
      desc: 'Date of birth field label',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: 'Nationality field label',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: 'Gender field label',
      args: [],
    );
  }

  /// `Save Profile`
  String get saveProfile {
    return Intl.message(
      'Save Profile',
      name: 'saveProfile',
      desc: 'Save profile button text',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: 'Logout button text',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings screen title',
      args: [],
    );
  }

  /// `Common`
  String get common {
    return Intl.message(
      'Common',
      name: 'common',
      desc: 'Common section title in settings',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Language setting',
      args: [],
    );
  }

  /// `Enable custom theme`
  String get enableCustomTheme {
    return Intl.message(
      'Enable custom theme',
      name: 'enableCustomTheme',
      desc: 'Enable custom theme setting',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: 'Account section title in settings',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: 'Phone number setting',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: 'Email setting',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message(
      'Security',
      name: 'security',
      desc: 'Security section title in settings',
      args: [],
    );
  }

  /// `Change password`
  String get changePassword {
    return Intl.message(
      'Change password',
      name: 'changePassword',
      desc: 'Change password setting',
      args: [],
    );
  }

  /// `Use fingerprint`
  String get useFingerprint {
    return Intl.message(
      'Use fingerprint',
      name: 'useFingerprint',
      desc: 'Use fingerprint setting',
      args: [],
    );
  }

  /// `Enable Lock`
  String get enableLock {
    return Intl.message(
      'Enable Lock',
      name: 'enableLock',
      desc: 'Enable lock setting',
      args: [],
    );
  }

  /// `Misc`
  String get misc {
    return Intl.message(
      'Misc',
      name: 'misc',
      desc: 'Misc section title in settings',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: 'Terms of Service setting',
      args: [],
    );
  }

  /// `Open source licenses`
  String get openSourceLicenses {
    return Intl.message(
      'Open source licenses',
      name: 'openSourceLicenses',
      desc: 'Open source licenses setting',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: 'First name field label',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: 'Last name field label',
      args: [],
    );
  }

  /// `Invalid username`
  String get invalidUsername {
    return Intl.message(
      'Invalid username',
      name: 'invalidUsername',
      desc: 'Invalid username error',
      args: [],
    );
  }

  /// `Username is taken`
  String get usernameTaken {
    return Intl.message(
      'Username is taken',
      name: 'usernameTaken',
      desc: 'Username is taken error',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: 'Continue button text',
      args: [],
    );
  }

  /// `Set a password`
  String get setPassword {
    return Intl.message(
      'Set a password',
      name: 'setPassword',
      desc: 'Set a password title',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: 'Confirm password field label',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordMatch',
      desc: 'Passwords do not match error',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long`
  String get passwordLength {
    return Intl.message(
      'Password must be at least 8 characters long',
      name: 'passwordLength',
      desc: 'Password length error',
      args: [],
    );
  }

  /// `You must be at least 18 years old`
  String get ageRestriction {
    return Intl.message(
      'You must be at least 18 years old',
      name: 'ageRestriction',
      desc: 'Age restriction error',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: 'Male gender label',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: 'Female gender label',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: 'Other gender label',
      args: [],
    );
  }

  /// `Enter your status message`
  String get statusMessageHint {
    return Intl.message(
      'Enter your status message',
      name: 'statusMessageHint',
      desc: 'Status message hint',
      args: [],
    );
  }

  /// `Followers`
  String get followers {
    return Intl.message(
      'Followers',
      name: 'followers',
      desc: 'Followers label',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: 'Friends label',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Name label',
      args: [],
    );
  }

  /// `Native Language`
  String get nativeLanguage {
    return Intl.message(
      'Native Language',
      name: 'nativeLanguage',
      desc: 'Native language label',
      args: [],
    );
  }

  /// `Learning Language`
  String get learningLanguage {
    return Intl.message(
      'Learning Language',
      name: 'learningLanguage',
      desc: 'Learning language label',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: 'Country field label',
      args: [],
    );
  }

  /// `Joined in`
  String get joinedIn {
    return Intl.message(
      'Joined in',
      name: 'joinedIn',
      desc: 'Joined in label',
      args: [],
    );
  }

  /// `The selected image contains inappropriate content and cannot be uploaded.`
  String get errorMessage {
    return Intl.message(
      'The selected image contains inappropriate content and cannot be uploaded.',
      name: 'errorMessage',
      desc: 'Error message for inappropriate content',
      args: [],
    );
  }

  /// `Error processing image for inappropriate content.`
  String get errorProcessingImage {
    return Intl.message(
      'Error processing image for inappropriate content.',
      name: 'errorProcessingImage',
      desc: 'Error message for processing image',
      args: [],
    );
  }

  /// `Image uploaded successfully!`
  String get imageUploadedSuccessfully {
    return Intl.message(
      'Image uploaded successfully!',
      name: 'imageUploadedSuccessfully',
      desc: 'Message for successful image upload',
      args: [],
    );
  }

  /// `Error uploading image.`
  String get errorUploadingImage {
    return Intl.message(
      'Error uploading image.',
      name: 'errorUploadingImage',
      desc: 'Error message for uploading image',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: 'Online status',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: 'Offline status',
      args: [],
    );
  }

  /// `Moments`
  String get moments {
    return Intl.message(
      'Moments',
      name: 'moments',
      desc: 'Moments tab label',
      args: [],
    );
  }

  /// `Moments content goes here`
  String get momentsContent {
    return Intl.message(
      'Moments content goes here',
      name: 'momentsContent',
      desc: 'Content for Moments tab',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: 'Title for change language dialog',
      args: [],
    );
  }

  /// `Are you sure you want to change the app language?`
  String get areYouSureChangeLanguage {
    return Intl.message(
      'Are you sure you want to change the app language?',
      name: 'areYouSureChangeLanguage',
      desc: 'Confirmation message for changing language',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancel button text',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'Confirm button text',
      args: [],
    );
  }

  /// `Search Language`
  String get searchLanguage {
    return Intl.message(
      'Search Language',
      name: 'searchLanguage',
      desc: 'Hint text for language search field',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
