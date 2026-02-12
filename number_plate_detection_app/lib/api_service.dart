import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _basePredictVehicleUrl = 'http://164.100.140.208:5001';
  static const String _baseDetectLicensePlateUrl =
      'http://164.100.140.208:5000';

  Future<Map<String, dynamic>> predictVehicleType(Uint8List imageBytes) async {
    final url = Uri.parse('$_basePredictVehicleUrl/predict_vehicle_type');
    final request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
        filename: 'frame.jpg'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      print(
          'Failed to predict vehicle type. Status code: ${response.statusCode}');
      return {'error': 'Failed to predict vehicle type'};
    }
  }

  Future<Map<String, dynamic>> detectLicensePlate(Uint8List imageBytes) async {
    final url = Uri.parse('$_baseDetectLicensePlateUrl/detect');
    final request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
        filename: 'frame.jpg'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      print(
          'Failed to detect license plate. Status code: ${response.statusCode}');
      return {'error': 'Failed to detect license plate'};
    }
  }
}
