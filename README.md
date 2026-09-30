# Chat App

A Flutter chat application using Firebase for authentication, chat messages, file storage, and push notifications.

## Features

- Firebase Authentication for user sign-in and registration.
- Chat messages stored in Cloud Firestore.
- Chat screen with message bubbles and a message composer.
- User image selection, with Firebase Storage available for image uploads.
- Push notifications sent when a new message is added to the `chat` collection.
- Splash/loading screen while the app initializes.

The notification Cloud Function uses the message's `userName` as the notification title and `text` as the body. It sends the notification to the Firebase Cloud Messaging topic `chat`.

## Firebase services and tools

- **Firebase Authentication** — user authentication.
- **Cloud Firestore** — chat messages.
- **Firebase Storage** — image storage.
- **Firebase Cloud Messaging (FCM)** — push notifications.
- **Cloud Functions for Firebase (2nd gen)** — reacts to new Firestore messages.
- **Firebase CLI** — deploys Firebase resources.
- **FlutterFire CLI** — configures Firebase for Flutter.

## Requirements

Install the following tools:

- Git
- Flutter SDK and a supported Android/iOS development toolchain
- Node.js and npm (use the Node version specified in `functions/package.json`, if present)
- Firebase CLI

On Windows, install Firebase CLI with:

```powershell
npm install -g firebase-tools
```

Check the installations:

```powershell
flutter doctor
node --version
npm --version
firebase --version
```

## Get the project

```powershell
git clone <repository-url>
cd chat_app
flutter pub get
```

## Configure Firebase

1. Create or select a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable the Authentication sign-in provider used by the app.
3. Create a Cloud Firestore database.
4. Enable Firebase Storage and configure its security rules.
5. Enable Firebase Cloud Messaging.
6. Install and sign in to the Firebase CLI:

   ```powershell
   firebase login
   ```

7. From the project root, select the Firebase project:

   ```powershell
   firebase use <your-firebase-project-id>
   ```

   Check `.firebaserc` before using it: it may reference the original project.

8. Configure Firebase for Flutter. If needed, install FlutterFire CLI:

   ```powershell
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This generates or updates `lib/firebase_options.dart` and the platform-specific Firebase configuration files. The repository's `.gitignore` excludes `google-services.json` and `GoogleService-Info.plist`, so each developer must generate or obtain the appropriate local files for their platform.

Keep service-account private keys, passwords, and access tokens out of the repository. Firebase client configuration is not a substitute for secure Firestore and Storage rules.

## Install and deploy Cloud Functions

From the project root:

```powershell
cd functions
npm install
cd ..
firebase deploy --only functions
```

The function listens for documents created at `chat/{messageId}`. It expects each message to contain `userName` and `text`, then sends an FCM notification to the `chat` topic.

If deployment reports an Eventarc service-agent permission error, wait a few minutes after enabling the required Google Cloud APIs and retry. If it persists, check that the Eventarc service agent has the required IAM role.

## Run the app

From the project root:

```powershell
flutter run
```

Choose a connected device or start an Android emulator first. iOS builds require macOS and Xcode.

## Security notes

- Review Firestore and Storage security rules before deploying; do not use open/test rules in production.
- Restrict access so users can only perform operations allowed by the app.
- Never commit service-account keys, signing keys, passwords, or tokens.
- `firebase_options.dart` contains Firebase client configuration. Protect data with Firebase Security Rules and appropriate API restrictions.