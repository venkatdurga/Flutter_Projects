# Flutter Applications Suite

A collection of Flutter applications for vehicle detection, license plate recognition, and spoof detection.

## 📱 Applications

### 1. My App
Basic Flutter application with camera integration.

**Features:**
- Camera functionality
- HTTP API integration

**Dependencies:**
- `camera: ^0.10.0+3`
- `http: ^0.13.3`
- `flutter_plugin_android_lifecycle: ^2.0.6`

**How to Run:**
```bash
cd my_app
flutter pub get
flutter run
```

---

### 2. Number Plate Detection App
Application for detecting and recognizing vehicle license plates from images.

**Features:**
- Image picker for selecting photos
- License plate detection via API
- Upload and process vehicle images

**Dependencies:**
- `image_picker: ^0.8.5+3`
- `http: ^0.13.3`

**How to Run:**
```bash
cd number_plate_detection_app
flutter pub get
flutter run
```

**Usage:**
1. Launch the app
2. Select an image from gallery or take a photo
3. Upload the image for license plate detection
4. View detection results

---

### 3. RealOne
Advanced vehicle detection app with license plate recognition and vehicle type processing.

**Features:**
- Real-time camera capture
- License plate detection
- Vehicle type identification
- Image processing and analysis
- API integration for backend processing

**Dependencies:**
- `camera: ^0.10.0+1`
- `http: ^1.2.1`
- `image: ^3.0.1`
- `path_provider: ^2.0.3`

**How to Run:**
```bash
cd realone
flutter pub get
flutter run
```

**Usage:**
1. Open the app and grant camera permissions
2. Capture vehicle images
3. Process images for license plate and vehicle type detection
4. View analysis results

---

### 4. Vehicle Spoof Detection
Application for detecting spoofed or fake vehicle images to prevent fraud.

**Features:**
- Camera integration for live capture
- Image picker for gallery selection
- Spoof detection analysis
- Image saving functionality
- State management with Provider

**Dependencies:**
- `camera: ^0.10.0`
- `provider: ^6.0.0`
- `image: ^3.0.0`
- `path_provider: ^2.0.11`
- `http: ^0.13.6`
- `gallery_saver: ^2.3.2`
- `image_picker: ^0.8.4+4`

**How to Run:**
```bash
cd vehicle_spoof_detection
flutter pub get
flutter run
```

**Usage:**
1. Launch the app
2. Capture or select a vehicle image
3. Submit for spoof detection analysis
4. Review authenticity results

---

## 🚀 Prerequisites

- Flutter SDK (>=3.4.3 <4.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A physical device or emulator

## 📦 Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter
```

2. Navigate to the desired app directory
3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 🔧 Configuration

### API Endpoints
Each app uses API services defined in `api_service.dart`. Update the base URLs in respective files:
- `number_plate_detection_app/lib/api_service.dart`
- `realone/lib/api_service.dart`
- `vehicle_spoof_detection/lib/api_service.dart`

### Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for capturing vehicle images</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access required for selecting images</string>
```

## 🏗️ Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🧪 Testing

Run tests for any app:
```bash
cd <app-directory>
flutter test
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🛠️ Troubleshooting

**Camera not working:**
- Ensure permissions are granted
- Check physical device (emulators may have limited camera support)

**API connection issues:**
- Verify API endpoint URLs
- Check network connectivity
- Ensure backend services are running

**Build errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Update Flutter: `flutter upgrade`

## 📄 License

Private project - not published to pub.dev

## 👥 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📞 Support

For issues or questions, please contact the development team.
