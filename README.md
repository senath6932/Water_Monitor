<div align="center">

# 💧 Water Monitor

### Smart Water Usage Monitoring Application

A Flutter-based application for viewing water usage information, monitoring flow activity, and receiving alerts related to possible water leaks and unusual water consumption.

[![Flutter](https://img.shields.io/badge/Flutter-3.11.4+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime_Database-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Authentication](https://img.shields.io/badge/Firebase-Authentication-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/docs/auth)

</div>

---

## 📖 Table of Contents

1. [Overview](#-overview)
2. [Features](#-features)
3. [Built With](#-built-with)
4. [System Data](#-system-data)
5. [Getting Started](#-getting-started)
6. [Running the Application](#-running-the-application)
7. [Project Structure](#-project-structure)
8. [Alert Rules](#-alert-rules)
9. [Testing](#-testing)
10. [Notes](#-notes)

---

## 📖 Overview

**Water Monitor** is a Flutter application designed to help users monitor water usage information through a mobile-friendly interface.

The project uses Firebase services to support authentication, real-time water data access, and messaging. The application data model includes water flow rate, total usage, daily usage, leak-detection status, and the last update time. It also includes application components for displaying alerts and visualizing water-related information.

The repository contains Flutter platform folders for Android, iOS, web, Windows, Linux, and macOS, together with a separate `context_engine_python` folder.

## ✨ Features

### 📊 Water Usage Monitoring
- Display current water flow rate.
- View total water consumption.
- Monitor daily water usage.
- Show the current leak-detection state.
- Display the latest data update time.

### 🚨 Alerts and Notifications
- Provide an alerts interface.
- Use Firebase Realtime Database for alert-related data.
- Include Firebase Cloud Messaging support.
- Include local notification support.
- Support alert severity information such as critical and warning.

### 📈 Data Visualization
- Use charts to present water monitoring information.
- Support time-based display of information.
- Format relative time information for a clearer monitoring experience.

### 🔐 Firebase Integration
- Firebase initialization and core services.
- Firebase Authentication package integration.
- Firebase Realtime Database integration.
- Firebase Messaging integration.

## 🛠 Built With

| Technology / Package | Purpose |
|---|---|
| **Flutter** | Cross-platform application development |
| **Dart** | Main programming language |
| **Firebase Core** | Firebase initialization |
| **Firebase Authentication** | User authentication integration |
| **Firebase Realtime Database** | Real-time data storage and access |
| **Firebase Messaging** | Push messaging integration |
| **FL Chart** | Charts and data visualization |
| **Flutter Local Notifications** | Local notification support |
| **Timeago** | Relative time formatting |
| **Cupertino Icons** | iOS-style icons |
| **Flutter Test** | Flutter testing support |

---

## 📡 System Data

The water monitoring data model referenced in the project includes the following fields:

| Field | Description |
|---|---|
| `flowRate` | Current water flow rate |
| `totalUsage` | Total recorded water consumption |
| `dailyUsage` | Water consumption recorded for the day |
| `leakDetected` | Indicates whether a possible leak has been detected |
| `lastUpdated` | Timestamp of the latest water data update |

The application uses Firebase Realtime Database packages to access live data. The exact database URL, paths, and hardware communication configuration should be taken from the Firebase project and the corresponding application source.

## ⚙️ Getting Started

### Prerequisites

Install the following tools before running the project:

- Flutter SDK (Dart SDK version compatible with the project)
- Android Studio or Visual Studio Code
- Android Emulator, iOS Simulator (macOS only), or a connected device
- A Firebase project configured for the platforms you intend to run

### 1. Clone the Repository

```bash
git clone https://github.com/senath6932/Water_Monitor.git
cd Water_Monitor
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The project includes `firebase.json` and uses Firebase packages. Configure your own Firebase project for the target platform before running the application.

Use the official FlutterFire setup instructions to connect the app to Firebase:

[Firebase setup for Flutter](https://firebase.google.com/docs/flutter/setup)

Make sure the platform-specific Firebase configuration files are correctly added. Do not commit private credentials or service-account keys.

### 4. Check Connected Devices

```bash
flutter devices
```

---

## ▶️ Running the Application

Run the Flutter application using:

```bash
flutter run
```

To run on a specific connected device:

```bash
flutter run -d <device_id>
```

To create an Android APK:

```bash
flutter build apk
```

For other platforms, use the corresponding Flutter build command after completing that platform's setup.

---

## 📂 Project Structure

```text
Water_Monitor/
│
├── android/                  # Android platform project
├── ios/                      # iOS platform project
├── linux/                    # Linux platform project
├── macos/                    # macOS platform project
├── windows/                  # Windows platform project
├── web/                      # Web platform project
│
├── lib/                      # Main Flutter application source
├── test/                     # Flutter test files
├── context_engine_python/    # Separate Python context-engine component
│
├── firebase.json             # Firebase project configuration
├── pubspec.yaml              # Flutter dependencies and project settings
├── pubspec.lock              # Locked dependency versions
├── analysis_options.yaml      # Dart analysis and lint configuration
├── PROJECT_REVIEW_PACK.md    # Project review documentation
├── markdown.md               # Development notes for alert-generation changes
└── README.md
```

---

## 🚨 Alert Rules

The repository's development notes describe the following automatic alert conditions:

| Condition | Alert | Severity |
|---|---|---|
| Leak status changes from `false` to `true` | Possible leak | Critical |
| Water flow exceeds `1.0 L/min` between `00:00` and `05:59` | Night-time usage | Warning |

These conditions are documented in [`markdown.md`](./markdown.md) as requirements for alert-generation changes. Check the current application implementation and Firebase configuration to confirm which rules are active in your running version.

---

## 🧪 Testing

The project includes a Flutter `test/` directory and the `flutter_test` development dependency.

Run the available tests with:

```bash
flutter test
```

Run static analysis with:

```bash
flutter analyze
```

---

## 📝 Notes

- Firebase must be configured for the target platform before Firebase-dependent features can work.
- The repository includes a `context_engine_python` directory; its setup and execution instructions should be checked within that folder.
- Hardware or Arduino integration details should be confirmed from the relevant source files and project documentation.
- Do not add Firebase service-account keys, private API keys, or other secrets to the repository.

---

<div align="center">

**Water Monitor**

*Making water usage information easier to monitor.*

</div>
