import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'upload_screen.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const WelcomeScreen({super.key, required this.camera});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _licensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _quitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: _animation,
              child: const Column(
                children: [
                  Text(
                    'PUCC 2.0',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Welcome to the Pollution Check App',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Enter License Plate Number',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadScreen(
                      camera: widget.camera,
                      expectedLicensePlate: _licensePlateController.text,
                    ),
                  ),
                );
              },
              child: const Text('Start Camera'),
            ),
            ElevatedButton(
              onPressed: _quitApp,
              child: const Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }
}
