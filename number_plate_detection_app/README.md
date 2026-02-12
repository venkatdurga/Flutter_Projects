# Number Plate Detection App

Flutter application for detecting and recognizing vehicle license plates from images.

## Features

- Image picker for selecting photos from gallery or camera
- License plate detection via API
- Upload and process vehicle images
- Real-time detection results

## Dependencies

- `image_picker: ^0.8.5+3`
- `http: ^0.13.3`

## Installation

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Usage

1. Launch the app
2. Select an image from gallery or take a photo
3. Upload the image for license plate detection
4. View detection results

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Configuration

Update API endpoint in `lib/api_service.dart` with your backend URL.
