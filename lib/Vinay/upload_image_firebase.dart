import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  String? _imageUrl; // Store the image URL fetched from Firestore
  final picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Pick image from gallery
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web: Get the bytes of the image
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
        });

        // Upload image immediately after selection
        uploadImage();
      }
    } else {
      print('No image selected.');
    }
  }

  // Upload image to Firebase Storage and store its URL in Firestore
  Future uploadImage() async {
    if (_imageBytes != null) {
      try {
        // Reference to Firebase Storage
        Reference ref = storage.ref().child('profileImages/${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Upload file to Firebase Storage
        UploadTask uploadTask = ref.putData(_imageBytes!);

        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the download URL in Firestore
        await firestore.collection('users').doc('profile').set({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _imageUrl = downloadUrl; // Set the image URL for display
        });

        print("Profile image uploaded and URL saved in Firestore: $downloadUrl");
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected.');
    }
  }

  // Fetch the profile image URL from Firestore when the screen loads
  Future<void> fetchProfileImageUrl() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore.collection('users').doc('profile').get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          _imageUrl = snapshot.data()!['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileImageUrl(); // Fetch image URL on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Profile Picture',
          style: GoogleFonts.beVietnamPro(
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _imageUrl != null
              ? Image.network(
            _imageUrl!,
            height: 250,
            width: 250,
          ) // Display the image fetched from Firestore
              : _imageBytes != null
              ? Image.memory(
            _imageBytes!,
            height: 250,
            width: 250,
          ) // Display the selected image if not yet uploaded
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No image selected.',
              style: GoogleFonts.beVietnamPro(
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.black.withOpacity(.2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: pickImage,
                    icon: Icon(
                      Icons.image,
                      color: Colors.black.withOpacity(.3),
                    ),
                    iconSize: 60,
                    hoverColor: Colors.blueAccent,
                    tooltip: "Pick Image",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
