import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:country_codes_info/country_codes_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart'; // Import the generated localization file
import 'screens/signup_step1.dart';
import 'screens/signup_step2.dart';
import 'screens/signup_step3.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart'; // Make sure to import the profile screen
import 'services/auth_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CountryCodes.init(); // Initialize the country codes
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/signup_step1': (context) => const SignUpStep1(),
          '/signup_step2': (context) => const SignUpStep2(),
          '/signup_step3': (context) => const SignUpStep3(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/profile': (context) => const ProfileScreen(), // Add the route for the profile screen
        },
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}
