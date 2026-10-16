# NeuroInsight-PD (Mobile App)

NeuroInsight-PD is a multi-modal Parkinson's disease detection and telemonitoring system. This repository is the **patient mobile application**, built with Flutter. Patients record their tests in the app, an AI model analyses them, and a doctor reviews the result on the web portal and sends a report back to the patient.

The doctor and radiologist web application is a separate project (`SeniorProject-Web-`). Both applications use the same Firebase project.

## Features

- Sign up and log in with a National ID and password
- Password reset by email
- Upload a voice recording (CSV of voice features) and get an AI prediction
- Upload a spiral drawing image and get an AI prediction
- View uploaded tests in "My Uploads", with full-size images
- Receive and read the doctor's reports
- View and update the profile (email and phone)

## How it works

1. The patient logs in (Firebase Authentication).
2. The patient uploads a voice CSV or a spiral drawing.
3. The app sends the data to the model server (hosted on Render) and gets a prediction.
4. The test and its prediction are saved in Cloud Firestore with the status `pending_review`. Drawing images are stored in Cloudinary.
5. The doctor reviews the test on the web portal and submits a report.
6. The patient sees the submitted report in the Reports tab.

## Project structure

```
lib/
  main.dart            App entry point (starts Firebase)
  firebase_options.dart
  models/              Data classes (user, report, sign-up data)
  screens/             App screens (login, sign-up, home, upload, reports, profile)
  services/            db_helper.dart (Firebase), voice_model_service.dart,
                       drawing_model_service.dart, cloudinary_upload_service.dart
  theme/               App colors and theme
  widgets/             Reusable widgets
test/                  Unit (widget) tests
integration_test/      Integration, system, and performance tests
```

## Requirements

- Flutter SDK 3.x (Dart `>=3.0.0 <4.0.0`)
- Xcode and an iOS simulator, or an Android emulator
- Internet connection (Firebase, the model servers, and Cloudinary)

## Getting started

```bash
flutter pub get      # install the packages
flutter run          # run the app
```

## Running the tests

```bash
# Unit tests
flutter test test/auth_screens_test.dart --reporter expanded

# Integration, system, and performance tests (use a simulator or device)
flutter test integration_test/app_test.dart -d "iPhone 15" -r expanded
flutter test integration_test/system_test.dart -d "iPhone 15" -r expanded
flutter test integration_test/performance_test.dart -d "iPhone 15" -r expanded
```

The model servers run on a free hosting plan and sleep when they are not used, so the first request can take up to one minute.

## Built with

Flutter and Dart, Firebase Authentication, Cloud Firestore, Cloudinary, and Python model servers on Render.