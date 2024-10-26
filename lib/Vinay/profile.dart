import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html; // Conditional import

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web: Get the bytes of the image
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  Future uploadImage() async {
    if (_imageBytes != null) {
      try {
        // Get the current user's UID
        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Reference to Firebase Storage
        Reference ref = storage.ref().child('app_profile_images').child('$uid.jpg');

        // Upload file to Firebase Storage (for both Web and Mobile)
        UploadTask uploadTask = ref.putData(_imageBytes!);

        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update the user's profile with the new photo URL
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);

        setState(() {
          SnackBar(content: Text("Image Uploded Successfully...",style: GoogleFonts.beVietnamPro(
            textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)),backgroundColor: Colors.green,);
          print("Profile image uploaded: $downloadUrl");
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Profile Picture',
        style: GoogleFonts.beVietnamPro(
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),),backgroundColor: Colors.blue,),
      body: Column(
        children: [
          _imageBytes != null
              ? (kIsWeb
              ? Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Image.memory(_imageBytes!, height: 250,width: 250,),
              ) // For Web, use Image.memory
              : Image.memory(_imageBytes!,height: 250,width: 250,)) // For Mobile, display as memory as well
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No image selected.',style: GoogleFonts.beVietnamPro(
              textStyle: TextStyle(fontWeight: FontWeight.bold),),),
          ),

          SizedBox(height: 40,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(onPressed: pickImage,
                      icon: Icon(Icons.image, color: Colors.black.withOpacity(.3),)
                      ,iconSize: 60,hoverColor: Colors.blueAccent,tooltip: "Pick Image",),

                    Text("Pick Image",style: GoogleFonts.beVietnamPro(
                      textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),))
                  ],
                ),

                SizedBox(width: 70,),
                Column(
                  children: [
                    IconButton(onPressed: uploadImage,
                      icon: Icon(Icons.cloud_upload,color: Colors.black.withOpacity(.3)),
                      iconSize: 60,hoverColor: Colors.blue,tooltip: "Upload Image",),

                    Text("Upload Image",style: GoogleFonts.beVietnamPro(
                      textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),))

                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
