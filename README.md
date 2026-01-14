# Goal Setting App

A professional, feature-rich Flutter application designed to help users manage their personal goals, track progress, and visualize success. Built with a focus on Clean Architecture, scalability, and modern UI/UX principles.

## Project Overview

The **Goal Setting App** allows users to define objectives, break them down into milestones, and track their completion status in real-time. It leverages the power of Firebase for backend services while ensuring a smooth, responsive user experience with local state management and offline-capable architecture.

## Key Features

*   **Goal Management**: Create, read, update, and delete (CRUD) goals with titles, descriptions, and deadlines.
*   **Progress Tracking**: Visual progress bars with dynamic color coding (Not Started, In Progress, Completed).
*   **Smart Search & Filtering**: Instantly filter goals by status or search by keywords with text highlighting.
*   **Rich Media Attachments**: Upload and view images associated with goals (powered by Firebase Storage and CachedNetworkImage).
*   **Theme Customization**: Toggle between Light and Dark modes with preference persistence.
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
│       ├── services/       # Backup services
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
    git clone https://github.com/mrgargom/goal-manager-app.git
    cd goal-manager-app
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

## AI Development Context

This project was developed with the assistance of AI tools. Below is a summary of the prompts and development logs used to build the application.

### Used Prompts (Core Requirements)

// Create a Goal model for a goal app.
// Properties:
// - id (String)
// - title (String)
// - description (String)
// - progress (int from 0 to 100)
// - milestones (List<String>)
// - createdAt (Timestamp)
// Add Firestore serialization methods.


// Create GoalRepository to manage Firestore CRUD.
// Responsibilities:
// - Stream all goals in real time
// - Add a new goal
// - Delete a goal
// Use Firestore collection name "goals".


// Create GoalListScreen.
// Display goals using StreamBuilder.
// Show progress using LinearProgressIndicator.
// Allow updating progress.
// Allow deleting goals.
// FloatingActionButton to add a new goal.


// ADD PROGRESS FILTER FEATURE.
//
// Context:
// - Flutter Goal Setting App
// - Firebase + Cloud Firestore
// - Provider state management
//
// Requirements:
// - Add an enum GoalFilter with values:
//   * all
//   * notStarted (progress == 0)
//   * inProgress (progress > 0 && progress < 100)
//   * completed (progress == 100)
//
// - Store the current filter in GoalProvider
// - Provide a setter method to change the filter
// - Expose a filteredGoals stream based on the selected filter
// - Keep Firestore stream as the data source


"Here is my theme configuration.
Please check for Material 3 compliance:
Is useMaterial3: true set?
Am I using ColorScheme.fromSeed or a proper color palette?
Is there a clear distinction between Light and Dark modes?
Are Google Fonts implemented correctly in the TextTheme?


"I have implemented Firebase Auth with Provider.
Check my logic:
I created an AuthService to handle Firebase calls.
I used ChangeNotifierProxyProvider in main.dart to pass the userId from AuthProvider to GoalProvider.
I created an AuthWrapper to switch between Login and Home screens.
Please review my code snippet  confirm if this safely handles the user session and data security."


The application was built based on the following synthesized requirements prompt:

> "Create a robust Flutter Goal Management application using **Provider** for state management and **Firebase** for the backend. The app should follow **Clean Architecture** principles.
>
> **Key Functionalities:**
> 1.  **Authentication**: Email/Password login and signup via Firebase Auth.
> 2.  **CRUD Operations**: Add, Edit, Delete, and View goals.
> 3.  **Progress Tracking**: Visual progress bars and percentage updates.
> 4.  **Search & Filter**: Client-side filtering and searching of goals.
> 5.  **Backup System**: Functionality to Import/Export goals to/from JSON files.
> 6.  **Theming**: Support for dynamic Dark/Light mode switching.
> 7.  **Localization**: Initially requested with comprehensive Arabic educational comments (later cleaned for production)."

### AI Logs (Development Changelog)

*   **Phase 1 - Initialization & Structure**:
    *   Established the folder structure (MVVM/Clean Architecture).
    *   Configured Firebase dependencies (`firebase_core`, `cloud_firestore`, `firebase_auth`).
*   **Phase 2 - Core Implementation**:
    *   Implemented `GoalProvider` for state management.
    *   Created `GoalListScreen` with `StreamBuilder` for real-time updates.
    *   Built `BackupService` for handling local JSON storage operations.
*   **Phase 3 - UI/UX Refinements**:
    *   Added `PopupMenuButton` in the AppBar for Import/Export actions.
    *   Implemented `Slider` dialogs for updating goal progress.
    *   Refined `GoalCard` with search text highlighting.
*   **Phase 4 - Documentation & Educational Support**:
    *   Previously added detailed Arabic comments to all source files (Screens, Providers, Services) to explain logical flows for educational purposes.
*   **Phase 5 - Production Cleanup**:
    *   Removed inline educational comments to produce a clean, professional codebase.
    *   Finalized `README.md` with project documentation.
