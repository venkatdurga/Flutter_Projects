# RealOne

Advanced vehicle detection app with license plate recognition and vehicle type processing.

## Features

- Real-time camera capture
- License plate detection
- Vehicle type identification
- Image processing and analysis
- API integration for backend processing

## Dependencies

- `camera: ^0.10.0+1`
- `http: ^1.2.1`
- `image: ^3.0.1`
- `path_provider: ^2.0.3`

## Installation

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Usage

1. Open the app and grant camera permissions
2. Capture vehicle images
3. Process images for license plate and vehicle type detection
4. View analysis results

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Configuration

Update API endpoint in `lib/api_service.dart` with your backend URL.

## Permissions

Ensure camera and storage permissions are granted in AndroidManifest.xml and Info.plist.
