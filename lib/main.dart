import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:products/addproduct.dart';
import 'package:products/splashscreen.dart';
import 'Vinay/profile.dart';
import 'auth/auth.dart';
import 'category/category_page.dart';
import 'category/mainCategoryFile.dart';
import 'category/navBar.dart';
import 'displaydata.dart';



void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();


  if (kIsWeb) {
    // Initialize Firebase for web
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBkY4A4Uj9FLel-tWXecIW9a9vC24QFlIE",
        projectId: "flutter-firebase-lecture",
        storageBucket: "flutter-firebase-lecture.appspot.com",
        messagingSenderId: "269006106399",
        appId: "1:269006106399:web:a722c43ed26b120ca14a2a",  // Use web-specific appId
      ),
    );
  } else {
    // Initialize Firebase for Android/iOS
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: MainMenu(),
    );
  }
}


