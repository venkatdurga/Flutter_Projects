import 'dart:typed_data';
import 'api_service.dart';

class VehicleTypeProcessing {
  final ApiService _apiService = ApiService();
  final int _totalFrames = 20;
  double _sumOfConfidences = 0.0;
  int _processedFrames = 0;
  final Map<String, int> _vehicleTypeCounts =
      {}; // To keep track of vehicle type counts

  int get totalFrames => _totalFrames;
  int get processedFrames => _processedFrames;

  Future<Map<String, dynamic>> processFrame(Uint8List imgData) async {
    final result = await _apiService.predictVehicleType(imgData);
    if (!result.containsKey('error')) {
      final vehicleType = result['vehicle_type'];
      final confidence = result['confidence'];

      _sumOfConfidences += confidence;
      _processedFrames++;

      // Update vehicle type count
      if (_vehicleTypeCounts.containsKey(vehicleType)) {
        _vehicleTypeCounts[vehicleType] = _vehicleTypeCounts[vehicleType]! + 1;
      } else {
        _vehicleTypeCounts[vehicleType] = 1;
      }
    }
    return result;
  }

  bool get isProcessingComplete => _processedFrames >= _totalFrames;

  double get averageConfidence =>
      _processedFrames > 0 ? _sumOfConfidences / _processedFrames : 0.0;

  Map<String, dynamic>? getBestDetection() {
    if (_vehicleTypeCounts.isEmpty) return null;

    // Find the most frequent vehicle type
    final mostFrequentType = _vehicleTypeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final confidence = averageConfidence;

    return {'text': mostFrequentType, 'confidence': confidence};
  }
}
