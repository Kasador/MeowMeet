import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'feed_screen.dart';
import 'map_screen.dart';
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
    FeedScreen(),
    ChatScreen(),
    MapScreen(),
    ProfileScreen(),
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
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: localizations.feed,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: localizations.chat,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: localizations.map,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: localizations.profile,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.backgroundColor,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
