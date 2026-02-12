import 'package:flutter/material.dart';
// import 'upload_screen.dart'; // Import the UploadScreen
import 'welcome_screen.dart'; // Import the WelcomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Plate Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(), // Set the WelcomeScreen as the home
    );
  }
}
