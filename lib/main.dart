import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:country_codes_info/country_codes_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
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

  // Get the saved language preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language_code');

  runApp(MainApp(locale: languageCode != null ? Locale(languageCode) : null));
}

class MainApp extends StatefulWidget {
  final Locale? locale;

  const MainApp({Key? key, this.locale}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext context) => const SplashScreen();
              break;
            case '/signup_step1':
              builder = (BuildContext context) => const SignUpStep1();
              break;
            case '/signup_step2':
              builder = (BuildContext context) => const SignUpStep2();
              break;
            case '/signup_step3':
              builder = (BuildContext context) => const SignUpStep3();
              break;
            case '/home':
              builder = (BuildContext context) => const HomeScreen();
              break;
            case '/login':
              builder = (BuildContext context) => const LoginScreen();
              break;
            case '/settings':
              builder = (BuildContext context) => const SettingsScreen();
              break;
            case '/profile':
              builder = (BuildContext context) => const ProfileScreen();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => builder(context),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
            settings: settings,
          );
        },
        locale: _locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          LocaleNamesLocalizationsDelegate(),
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}
