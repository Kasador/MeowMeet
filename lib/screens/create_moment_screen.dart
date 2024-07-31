import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateMomentScreen extends StatefulWidget {
  @override
  _CreateMomentScreenState createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _postMoment() async {
    if (_contentController.text.isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some content or an image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('moments/${user.uid}/${DateTime.now().toIso8601String()}.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => {});
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    final momentData = {
      'userId': user.uid,
      'timestamp': Timestamp.now(),
      'content': _contentController.text,
      'imageUrl': imageUrl,
    };

    await FirebaseFirestore.instance.collection('moments').add(momentData);

    setState(() {
      _contentController.clear();
      _image = null;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Moment posted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Moment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Share something...',
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                if (_image != null) Image.file(_image!, height: 100),
              ],
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : _postMoment,
              child: _isUploading ? CircularProgressIndicator() : Text('Post Moment'),
            ),
          ],
        ),
      ),
    );
  }
}
