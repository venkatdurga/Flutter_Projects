// ignore_for_file: avoid_print

class LicensePlateDetector {
  final int windowSize;
  final double confidenceThreshold;
  final int frameSkip;
  List<Map<String, dynamic>> _detections = [];

  LicensePlateDetector({
    required this.windowSize,
    required this.confidenceThreshold,
    required this.frameSkip,
  });

  void addDetection(String text, double confidence) {
    if (confidence >= confidenceThreshold) {
      if (_detections.length >= windowSize) {
        _detections.removeAt(0);
      }
      _detections.add({'text': text, 'confidence': confidence});
      print("Added detection: $text with confidence: $confidence");
    } else {
      print("Detection not added due to low confidence.");
    }
  }

  Map<String, dynamic>? getBestDetection() {
    if (_detections.isEmpty) {
      print("No detections available.");
      return null;
    }

    var frequencyMap = <String, int>{};
    for (var detection in _detections) {
      final text = detection['text'] as String;
      frequencyMap[text] = (frequencyMap[text] ?? 0) + 1;
    }

    String mostFrequentText = frequencyMap.keys.first;
    for (var text in frequencyMap.keys) {
      if (frequencyMap[text]! > frequencyMap[mostFrequentText]!) {
        mostFrequentText = text;
      }
    }

    double avgConfidence = _detections
            .where((d) => d['text'] == mostFrequentText)
            .map((d) => d['confidence'] as double)
            .reduce((a, b) => a + b) /
        frequencyMap[mostFrequentText]!;

    print("Most frequent text: $mostFrequentText");
    print("Average confidence for $mostFrequentText: $avgConfidence");

    return {'text': mostFrequentText, 'confidence': avgConfidence};
  }
}
