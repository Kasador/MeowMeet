import 'package:flutter/material.dart';

class RandomChatScreen extends StatelessWidget {
  const RandomChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Chat'),
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
