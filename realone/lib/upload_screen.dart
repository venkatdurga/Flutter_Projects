// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'license.dart';
import 'welcome_screen.dart';
import 'vehicle_type_processing.dart';

class UploadScreen extends StatefulWidget {
  final CameraDescription camera;
  final String expectedLicensePlate;

  const UploadScreen(
      {super.key, required this.camera, required this.expectedLicensePlate});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _frameCount = 0;
  final int _frameSkip = 30; // Process every 35th frame
  bool _inferenceRunning = false;
  bool _inferenceStarted = false;
  int _currentPhase =
      0; // 0 for vehicle type prediction, 1 for number plate detection
  bool _moveToNextPhaseRequested = false;
  bool _isNextPhaseEnabled = false;
  final ApiService _apiService = ApiService();
  late VehicleTypeProcessing _vehicleTypeProcessing;
  String _licensePlateResult = '';
  String _vehicleTypeText = '';
  String _spoofResultText = '';
  String _matchingResult = '';
  late AnimationController _animationController;
  // late Animation<double> _animation;
  final LicensePlateDetector detector = LicensePlateDetector(
    windowSize: 5,
    confidenceThreshold: 0.5,
    frameSkip: 0, // Process every frame
  );

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // _animation = CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.easeIn,
    // );
    _vehicleTypeProcessing = VehicleTypeProcessing();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startInference() async {
    try {
      await _initializeControllerFuture;
      _controller.startImageStream((CameraImage image) {
        if (_frameCount % _frameSkip == 0) {
          _processCameraImage(image);
        }
        _frameCount++;
      });
      setState(() {
        _inferenceStarted = true;
        _inferenceRunning = true;
      });
      print('Camera and inference started');
    } catch (e) {
      print('Error starting camera and inference: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_inferenceRunning) {
      try {
        final imgData = _convertYUV420ToImage(image);
        if (imgData != null) {
          if (_currentPhase == 0) {
            final result = await _vehicleTypeProcessing.processFrame(imgData);
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
        final spoofResult = result['spoof_result'];
        // final vehicleType = result['vehicle_type'];
        // final confidence = result['confidence'];

        // Continuously update the spoof result
        _spoofResultText = 'Spoof Result: $spoofResult';
        // print("Handling vehicleType result: $vehicleType with confidence: $confidence");

        if (_vehicleTypeProcessing.isProcessingComplete) {
          // Use the most frequent result and average confidence
          final bestDetection = _vehicleTypeProcessing.getBestDetection();
          if (bestDetection != null) {
            _vehicleTypeText =
                'Most Frequent Vehicle Type: ${bestDetection['text']} (Confidence: ${bestDetection['confidence'].toStringAsFixed(2)}%)';
          } else {
            _vehicleTypeText =
                'No vehicle detected with sufficient confidence.';
          }
          _inferenceRunning = false;
          _isNextPhaseEnabled = true; // Enable Next Phase button
        } else {
          _vehicleTypeText = 'Under Processing....';
          // Update UI with continuous results
          // if (confidence >= 50) {
          //   _vehicleTypeText =
          //       'Detected Vehicle Type: $vehicleType (Confidence: ${confidence.toStringAsFixed(2)}%)';
          // } else {
          //   _vehicleTypeText =
          //       'No vehicle detected with sufficient confidence.';
          // }
        }
      }

      if (_moveToNextPhaseRequested) {
        _currentPhase = 1;
        _isNextPhaseEnabled = false; // Disable the Next Phase button once moved
        _moveToNextPhaseRequested = false;
      }
    });

    _animationController.forward();
  }

  void _handleLicensePlateResult(Map<String, dynamic> result) {
    setState(() {
      if (result.containsKey('error')) {
        _licensePlateResult = 'Error: ${result['error']}';
        _matchingResult = 'Error in detection.';
      } else {
        final numberPlate = result['text'];
        final detectionConfidence = (result['confidence'] as num).toDouble();
        print(
            "Handling license plate result: $numberPlate with confidence: $detectionConfidence");
        detector.addDetection(numberPlate, detectionConfidence);

        final bestDetection = detector.getBestDetection();
        if (bestDetection != null) {
          _licensePlateResult =
              'Detected License Plate: ${bestDetection['text']} (Confidence: ${bestDetection['confidence'].toStringAsFixed(2)}%)';

          if (bestDetection['text'].toUpperCase() ==
              widget.expectedLicensePlate.toUpperCase()) {
            _matchingResult = 'Text Matched!';
            _inferenceRunning = false;
          } else {
            _matchingResult = 'Text Mismatch.';
          }
        } else {
          _licensePlateResult =
              'No license plate detected with sufficient confidence.';
          _matchingResult = 'No text detected.';
        }
      }
    });
    _animationController.forward();
  }

  void _quitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _inferenceStarted
                        ? (_inferenceRunning
                            ? (_currentPhase == 0
                                ? 'Running Vehicle Type Prediction...'
                                : 'Running License Plate Detection...')
                            : 'Inference Paused')
                        : 'Waiting for Inference to Start...',
                  ),
                ),
                if (_currentPhase == 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (!_vehicleTypeProcessing.isProcessingComplete)
                          LinearProgressIndicator(
                            value: _vehicleTypeProcessing.processedFrames /
                                _vehicleTypeProcessing.totalFrames,
                          ),
                        // const SizedBox(height: 8.0),
                        // Text(
                        //   'Frames Processed: ${_vehicleTypeProcessing.processedFrames}/${_vehicleTypeProcessing.totalFrames}',
                        //   style: const TextStyle(fontSize: 16.0),
                        // ),
                        const SizedBox(height: 8.0),
                        Text(_vehicleTypeText.isNotEmpty
                            ? _vehicleTypeText
                            : 'No results yet.'),
                        const SizedBox(height: 8.0),
                        Text(_spoofResultText.isNotEmpty
                            ? _spoofResultText
                            : 'No spoof result yet.'),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(_licensePlateResult.isNotEmpty
                            ? _licensePlateResult
                            : 'No license plate detected.'),
                        const SizedBox(height: 8.0),
                        Text(
                          _matchingResult,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: _matchingResult == 'Text Matched!'
                                  ? Colors.green
                                  : Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _inferenceRunning
                          ? () {
                              setState(() {
                                _inferenceRunning = false;
                              });
                            }
                          : _startInference,
                      child: Icon(
                          _inferenceRunning ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isNextPhaseEnabled
                          ? () {
                              setState(() {
                                _moveToNextPhaseRequested = true;
                                _inferenceRunning =
                                    false; // Stop inference for the phase transition
                              });
                            }
                          : null,
                      child: const Text('Next Phase'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _quitApp,
                      child: const Text('Quit'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WelcomeScreen(camera: widget.camera),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
