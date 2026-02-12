import 'package:flutter/material.dart';
import 'upload_screen.dart'; // Import the UploadScreen

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the License Plate Detection App!',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the UploadScreen when pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadScreen()),
                );
              },
              child: Text('Start'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Exit the app when Quit button is pressed
                Navigator.of(context).pop();
              },
              child: Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }
}
