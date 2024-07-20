import 'package:flutter/material.dart';
import '../generated/l10n.dart';

class RandomChatScreen extends StatelessWidget {
  const RandomChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.randomChat),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}
