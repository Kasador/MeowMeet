import 'package:flutter/material.dart';
import 'package:navigation_view/item_navigation_view.dart';
import 'package:navigation_view/navigation_view.dart';
import 'chat_screen.dart';
import 'feed_screen.dart';
import 'map_screen.dart';
import 'random_chat_screen.dart';
import 'profile_screen.dart';
import '../theme.dart';
import '../generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ProfileScreen(),
    ChatScreen(),
    RandomChatScreen(),
    MapScreen(),
    FeedScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppTheme.primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40, right: 20, left: 20), // Adjust padding to prevent overflow
          child: NavigationView(
            onChangePage: (index) {
              _onItemTapped(index);
            },
            color: AppTheme.primaryColor,
            curve: Curves.easeInQuint,
            durationAnimation: const Duration(milliseconds: 300),
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha(0),
                Colors.white.withOpacity(0.2)
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: const [0.0, 1.0],
              tileMode: TileMode.clamp
            ),
            items: [
              ItemNavigationView(
                childAfter: const Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
                childBefore: Icon(Icons.person_outline, color: AppTheme.secondaryColor.withAlpha(60), size: 30),
              ),
              ItemNavigationView(
                childAfter: const Icon(Icons.chat, color: AppTheme.primaryColor, size: 30),
                childBefore: Icon(Icons.chat_outlined, color: AppTheme.secondaryColor.withAlpha(60), size: 30),
              ),
              ItemNavigationView(
                childAfter: const Icon(Icons.shuffle_on_outlined, color: AppTheme.primaryColor, size: 30),
                childBefore: Icon(Icons.shuffle, color: AppTheme.secondaryColor.withAlpha(60), size: 30),
              ),
              ItemNavigationView(
                childAfter: const Icon(Icons.map, color: AppTheme.primaryColor, size: 30),
                childBefore: Icon(Icons.map_outlined, color: AppTheme.secondaryColor.withAlpha(60), size: 30),
              ),
              ItemNavigationView(
                childAfter: const Icon(Icons.dynamic_feed, color: AppTheme.primaryColor, size: 30),
                childBefore: Icon(Icons.dynamic_feed_outlined, color: AppTheme.secondaryColor.withAlpha(60), size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
