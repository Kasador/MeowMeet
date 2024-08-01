import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:country_codes_info/country_codes_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  // Disable rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Locale? _locale;
  bool _isPresenceSetup = false;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
    WidgetsBinding.instance.addObserver(this);
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupPresence(user);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference statusRef = FirebaseDatabase.instance.ref('status/${user.uid}');
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      final DateTime now = DateTime.now();

      if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
        // Update lastActive field with the current time and set status to offline
        await statusRef.update({
          'last_changed': ServerValue.timestamp,
          'state': 'offline',
        });
        await userRef.update({
          'lastActive': now.toIso8601String(),
          'status': 'offline',
        });
      } else if (state == AppLifecycleState.resumed) {
        // Set status to online when the app is resumed
        await statusRef.update({
          'state': 'online',
        });
        await userRef.update({
          'status': 'online',
        });
      }
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _setupPresence(User user) async {
    if (_isPresenceSetup) return;
    _isPresenceSetup = true;

    DatabaseReference statusRef = FirebaseDatabase.instance.ref('status/${user.uid}');
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    // Define user status
    Map<String, dynamic> isOnline = {
      "state": "online",
      "last_changed": ServerValue.timestamp,
    };

    Map<String, dynamic> isOffline = {
      "state": "offline",
      "last_changed": ServerValue.timestamp,
    };

    // Set the user's status to online when they are connected
    DatabaseReference connectedRef = FirebaseDatabase.instance.ref('.info/connected');
    connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        statusRef.set(isOnline);
        userRef.update({
          'status': 'online',
          'lastActive': DateTime.now().toIso8601String(),
        });
        statusRef.onDisconnect().set(isOffline);
        userRef.onDisconnect().update({
          'status': 'offline',
          'lastActive': DateTime.now().toIso8601String(),
        });
      }
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
