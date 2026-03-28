# Tellme Chat App

Tellme is a modern, real-time messaging application built with Flutter and Firebase. It features a stunning, premium dark theme design with real-time text and image messaging, Google Sign-In, and user profile management.

## 🌟 Features

* **Real-time Messaging:** Fast and reliable text and image chat using Cloud Firestore.
* **Premium UI/UX:** A beautiful, responsive dark theme design with smooth animations and dynamic components.
* **Authentication:** Secure Google Sign-In via Firebase Auth.
* **Media Sharing:** Send images directly from your camera or gallery using Firebase Storage.
* **Emoji Picker:** Integrated emoji support for expressive messaging.
* **Push Notifications:** Stay updated with Firebase Cloud Messaging (FCM).
* **Online Status & Last Seen:** Track when users are online or when they were last active.
* **User Profiles:** Customizable profiles with avatars and "About" information.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend:** [Firebase](https://firebase.google.com/)
  * Cloud Firestore (Database)
  * Firebase Authentication (Google Sign-In)
  * Firebase Storage (Image hosting)
  * Firebase Cloud Messaging (Push Notifications)
* **Key Packages:**
  * `cached_network_image`: Image caching
  * `emoji_picker_flutter`: Emoji support
  * `image_picker`: Camera and gallery access
  * `google_sign_in`: Authentication

## 🚀 Getting Started

Follow these instructions to get the app running on your local machine for development and testing.

### Prerequisites

1. Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
2. Install [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions.
3. A Firebase account to set up the backend.

### Setup Instructions

**1. Clone the repository & Install packages**
```bash
# Clone the project (if applicable)
git clone <your-repository-url>

# Navigate into the project directory
cd Tellme-app

# Install all dependencies
flutter pub get
```

**2. Configure Firebase**
To use this app, you must connect it to your own Firebase project:
* Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
* Enable **Authentication** (Google Sign-in), **Firestore Database**, and **Storage**.
* Register your Android/iOS apps in the Firebase console.
* Download the configuration files:
  * For Android: Place `google-services.json` in `android/app/`
  * For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`
* (Optional) Update the `.env` file if you are using specific API keys.

**3. Run the App**
Connect a physical device or start an emulator, then run:
```bash
flutter run
```

## 📱 How to Use the App

1. **Launch & Login:** Open the app and sign in securely using your Google account on the Splash Screen.
2. **Home Screen:** Once logged in, you'll see a list of users. You can search for specific users using the search icon in the AppBar.
3. **Chatting:** 
   * Tap on any user to open the `ChatScreen`.
   * Type a message in the input field or tap the 📷 / 🖼️ icons to send pictures.
   * Tap the 😀 icon to browse and send emojis.
4. **Profile Management:** 
   * From the Home Screen, tap the "More" (3 dots) menu or navigate to the Profile screen.
   * Here you can update your Profile Picture, Name, and "About" status.
   * You can also log out from this screen.

## 🐛 Troubleshooting

**"The named parameter 'bgColor' isn't defined" (Emoji Picker Error)**
If you see this error when compiling, it's because newer versions of `emoji_picker_flutter` removed the `bgColor` parameter from the root `Config` object. 
* **Fix:** You can safely remove the `bgColor` line from `emoji_picker_flutter` configurations, or use `skinToneConfig: const SkinToneConfig(dialogBackgroundColor: ...)` and `bottomActionBarConfig` depending on exactly what you want to color.

---
*Built with ❤️ using Flutter.*
