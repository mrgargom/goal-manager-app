# Goal Setting App

A professional, feature-rich Flutter application designed to help users manage their personal goals, track progress, and visualize success. Built with a focus on Clean Architecture, scalability, and modern UI/UX principles.

## Project Overview

The **Goal Setting App** allows users to define objectives, break them down into milestones, and track their completion status in real-time. It leverages the power of Firebase for backend services while ensuring a smooth, responsive user experience with local state management and offline-capable architecture.

## Key Features

*   **Goal Management**: Create, read, update, and delete (CRUD) goals with titles, descriptions, and deadlines.
*   **Progress Tracking**: Visual progress bars with dynamic color coding (Not Started, In Progress, Completed).
*   **Milestones**: Break down complex goals into smaller, achievable tasks.
*   **Smart Search & Filtering**: Instantly filter goals by status or search by keywords with text highlighting.
*   **Rich Media Attachments**: Upload and view images associated with goals (powered by Firebase Storage and CachedNetworkImage).
*   **Theme Customization**: Toggle between Light and Dark modes with preference persistence.
*   **Data Portability**: Export and Import goals via JSON for backup and restoration.
*   **Secure Authentication**: User sign-up and login functionality using Firebase Auth.

## Tech Stack

*   **Framework**: Flutter (Dart)
*   **Architecture**: MVVM (Model-View-ViewModel) using Clean Architecture principles.
*   **State Management**: `provider`
*   **Backend**: Firebase
    *   **Authentication**: Secure user management.
    *   **Cloud Firestore**: Real-time NoSQL database.
    *   **Storage**: Cloud storage for image assets.
*   **Local Persistence**: `shared_preferences` (for theme settings).
*   **File Handling**: `path_provider`, `file_picker` (for backups).
*   **UI Components**: Material 3, Google Fonts, Cached Network Image.

## Folder Structure

The project follows a feature-first Clean Architecture structure:

```
lib/
├── core/                   # Core utilities and configuration
│   └── theme/              # App theme and ThemeProvider
├── features/               # Feature-based modules
│   ├── auth/               # Authentication feature
│   │   ├── presentation/   # UI (Login, Signup)
│   │   └── state/          # Auth logic (AuthProvider)
│   └── goals/              # Main Goals feature
│       ├── data/           # Models and Repositories
│       ├── presentation/   # UI (Screens, Widgets)
│       ├── services/       # Backup/Export services
│       └── state/          # State management (GoalProvider)
├── shared/                 # Reusable widgets and constants
│   └── widgets/            # Common UI components (Buttons, etc.)
├── firebase_options.dart   # Firebase configuration
└── main.dart               # App entry point
```

## Setup Instructions

1.  **Prerequisites**:
    *   Flutter SDK installed (version 3.0+).
    *   Dart SDK installed.
    *   A Firebase project created.

2.  **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/goal-setting-app.git
    cd goal-setting-app
    ```

3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Firebase Configuration**:
    *   Install the Firebase CLI.
    *   Run `flutterfire configure` to connect the app to your Firebase project.
    *   Ensure **Authentication**, **Firestore**, and **Storage** are enabled in your Firebase Console.

5.  **Run the App**:
    ```bash
    flutter run
    ```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
