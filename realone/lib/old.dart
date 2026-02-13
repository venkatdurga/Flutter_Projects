import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Type and License Plate Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UploadScreen(camera: camera),
    );
  }
}

class ApiService {
  static const String _baseUrl = 'http://192.168.0.254:5000';

  Future<Map<String, dynamic>> predictVehicleType(Uint8List imageBytes) async {
    final url = Uri.parse('$_baseUrl/predict_vehicle_type');
    final request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
        filename: 'frame.jpg'));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        print(
            'Failed to predict vehicle type. Status code: ${response.statusCode}');
        return {'error': 'Failed to predict vehicle type'};
      }
    } catch (e) {
      print('Error predicting vehicle type: $e');
      return {'error': 'Error predicting vehicle type'};
    }
  }

  Future<Map<String, dynamic>> detectLicensePlate(Uint8List imageBytes) async {
    final url = Uri.parse('$_baseUrl/detect');
    final request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
        filename: 'frame.jpg'));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        print(
            'Failed to detect license plate. Status code: ${response.statusCode}');
        return {'error': 'Failed to detect license plate'};
      }
    } catch (e) {
      print('Error detecting license plate: $e');
      return {'error': 'Error detecting license plate'};
    }
  }
}

class UploadScreen extends StatefulWidget {
  final CameraDescription camera;

  const UploadScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ApiService _apiService = ApiService();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _frameCount = 0;
  final int _frameSkip = 30; // Process every 10th frame
  bool _inferenceRunning = false;
  bool _inferenceStarted = false;
  int _currentPhase =
      0; // 0 for vehicle type prediction, 1 for number plate detection
  bool _moveToNextPhaseRequested = false;
  String _vehicleTypeText = '';
  String _licensePlateText = '';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    try {
      await _initializeControllerFuture;
      _controller.startImageStream((CameraImage image) {
        if (_frameCount % _frameSkip == 0) {
          _processCameraImage(image);
        }
        _frameCount++;
      });
    } catch (e) {
      print('Error starting camera: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_inferenceStarted && _inferenceRunning) {
      try {
        final imgData = _convertYUV420ToImage(image);
        if (imgData != null) {
          if (_currentPhase == 0) {
            final result = await _apiService.predictVehicleType(imgData);
            _handleVehicleTypeResult(result);
          } else {
            final result = await _apiService.detectLicensePlate(imgData);
            _handleLicensePlateResult(result);
          }
        }
      } catch (e) {
        print('Error processing camera image: $e');
      }
    }
  }

  Uint8List? _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;

      img.Image imgData = img.Image(width, height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex =
              uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * width + x;

          final yValue = image.planes[0].bytes[index];
          final uValue = image.planes[1].bytes[uvIndex];
          final vValue = image.planes[2].bytes[uvIndex];

          final int r =
              (yValue + (1.370705 * (vValue - 128))).clamp(0, 255).toInt();
          final int g = (yValue -
                  (0.337633 * (uValue - 128)) -
                  (0.698001 * (vValue - 128)))
              .clamp(0, 255)
              .toInt();
          final int b =
              (yValue + (1.732446 * (uValue - 128))).clamp(0, 255).toInt();

          imgData.setPixel(x, y, img.getColor(r, g, b));
        }
      }

      return Uint8List.fromList(img.encodeJpg(imgData));
    } catch (e) {
      print('Error converting YUV420 to image: $e');
      return null;
    }
  }

  void _handleVehicleTypeResult(Map<String, dynamic> result) {
    setState(() {
      if (result.containsKey('error')) {
        _vehicleTypeText = 'Error: ${result['error']}';
      } else {
        final vehicleType = result['vehicle_type'];
        final confidence = result['confidence'];
        if (confidence >= 50) {
          _vehicleTypeText =
              'Detected Vehicle Type: $vehicleType (Confidence: $confidence%)';
        } else {
          _vehicleTypeText = 'No vehicle detected with sufficient confidence.';
        }
      }

      if (_moveToNextPhaseRequested) {
        _currentPhase = 1;
        _moveToNextPhaseRequested = false;
      }
    });
  }

  void _handleLicensePlateResult(Map<String, dynamic> result) {
    setState(() {
      if (result.containsKey('error')) {
        _licensePlateText = 'Error: ${result['error']}';
      } else {
        final numberPlate = result['text'];
        final detectionConfidence = result['confidence'];
        if (detectionConfidence > 00) {
          _licensePlateText =
              'Detected License Plate: $numberPlate (Confidence: $detectionConfidence%)';
        } else {
          _licensePlateText =
              'No license plate detected with sufficient confidence.';
        }
      }
    });
  }

  void _quitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(children: [
              Expanded(child: CameraPreview(_controller)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_inferenceStarted
                    ? (_inferenceRunning
                        ? (_currentPhase == 0
                            ? 'Running Vehicle Type Prediction...'
                            : 'Running License Plate Detection...')
                        : 'Inference Paused')
                    : 'Waiting for Inference to Start...'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    _currentPhase == 0 ? _vehicleTypeText : _licensePlateText),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _inferenceStarted = !_inferenceStarted;
                        _inferenceRunning = _inferenceStarted;
                      });
                    },
                    child: Text(_inferenceStarted ? 'Stop' : 'Start/Resume'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _moveToNextPhaseRequested = true;
                      });
                    },
                    child: Text('Next Phase'),
                  ),
                  ElevatedButton(
                    onPressed: _startCamera,
                    child: Icon(Icons.camera_alt),
                  ),
                  ElevatedButton(
                    onPressed: _quitApp,
                    child: Text('Quit'),
                  ),
                ],
              ),
            ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

void _quitApp() {
  SystemNavigator.pop();
}
