import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart'; // Import your ApiService

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _selectedImage;
  String _apiResponse = '';

  final ApiService apiService =
      ApiService(); // Create an instance of ApiService
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    // Open the image picker to select an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Convert the selected image to bytes
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImage = imageBytes; // Store the selected image bytes
        _apiResponse = ''; // Clear any previous API response
      });
    }
  }

  Future<void> _sendImageToAPI() async {
    if (_selectedImage == null) return;

    // Call the API to detect license plate
    final response = await apiService.detectLicensePlate(_selectedImage!);

    setState(() {
      if (response.containsKey('error')) {
        _apiResponse = response['error'];
      } else {
        // Extract only the text part from the response
        if (response['text'] != null) {
          _apiResponse = response['text']; // Get only the text part
        } else {
          _apiResponse =
              'No text detected'; // Handle case where no text is found
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image for License Plate Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendImageToAPI,
              child: Text('Send to API'),
            ),
            SizedBox(height: 16.0),
            if (_apiResponse.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Detected Number: $_apiResponse',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
