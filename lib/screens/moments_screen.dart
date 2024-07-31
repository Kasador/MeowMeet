import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MomentsScreen extends StatelessWidget {
  final String userId;

  MomentsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('moments')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading moments: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No moments found.'));
        }

        final moments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: moments.length,
          itemBuilder: (context, index) {
            final moment = moments[index];
            return ListTile(
              leading: moment['imageUrl'] != null ? Image.network(moment['imageUrl']) : null,
              title: Text(moment['content'] ?? ''),
              subtitle: Text(DateFormat.yMMMd().add_jm().format(moment['timestamp'].toDate())),
            );
          },
        );
      },
    );
  }
}
