# protocols_proj

An innovative Flutter-based mobile application designed to automate and streamline session attendance tracking using Bluetooth Low Energy (BLE) beacons.

## Overview

This project provides a modern solution to the age-old problem of manually tracking attendance. By leveraging BLE beacons placed in classrooms or session venues, the app can automatically verify and record a user's presence, ensuring accuracy and saving time for both organizers and attendees. The backend is powered by Firebase, providing real-time data synchronization and robust user authentication.

## Key Features

-   **Automated Attendance:** Detects nearby BLE beacons to mark attendance automatically. The system requires the user to be within a specific range for a set duration to prevent false check-ins.
-   **Secure Authentication:** Supports sign-in and sign-up using both email/password and Google Sign-In for a seamless user experience.
-   **Attendance History:** Allows users to view their complete attendance records for various courses, with states like 'attended' or 'absent'.
-   **Real-time Database:** Utilizes Firebase Realtime Database to store and sync user data, session schedules, and attendance records instantly.
-   **Cross-Platform:** Built with Flutter, enabling deployment on both Android and iOS from a single codebase (currently configured for Android).
-   **Password Management:** Includes a "Forgot Password" feature for easy account recovery.

## How It Works

1.  **Beacon Setup:** BLE beacons are configured in the Firebase database, each associated with a specific course or classroom.
2.  **BLE Scanning:** The app continuously scans for nearby Bluetooth devices when the "Take Attendance" feature is active.
3.  **Proximity Detection:** Upon detecting a known beacon, the app calculates the user's proximity based on the beacon's RSSI (Received Signal Strength Indicator).
4.  **Attendance Validation:** If the user remains within the required distance (e.g., 2 meters) for a specified duration (e.g., 120 seconds), the app cross-references the current time with the session schedule stored in Firebase.
5.  **Record Update:** If an active session is found, the user's attendance is marked as 'attended' in the Firebase Realtime Database.

## Technology Stack

-   **Frontend:** Flutter
-   **Backend & Database:** Firebase (Authentication, Realtime Database)
-   **Bluetooth Communication:** `flutter_blue_plus` package for BLE scanning.
-   **State Management:** `StatefulWidget` & `ValueNotifier`

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK installed.
-   A Firebase project.
-   An Android or iOS device/emulator.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/Sirye8/protocols-proj.git
    ```
2.  **Set up Firebase**
    -   Create a new Firebase project.
    -   Add an Android/iOS app to your Firebase project.
    -   Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) and place it in the respective app directory.
    -   Configure the Realtime Database and Authentication.
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Run the app**
    ```sh
    flutter run
    ```
