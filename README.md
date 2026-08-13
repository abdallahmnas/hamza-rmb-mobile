# Hamza RMB

A production-ready Flutter application built with a feature-first architecture, Riverpod for state management, GoRouter for navigation, and Dio for networking.

## Project Structure

This project follows a feature-first architecture, separating concerns into discrete modules:

```
lib/
├── app/               # Core application setup, routing, and theming
├── core/              # Reusable components, networking, storage, errors
├── features/          # Feature modules (e.g., home)
│   └── [feature_name]/
│       ├── data/      # Data sources, models, repository implementations
│       ├── domain/    # Entities, repository interfaces
│       └── presentation/ # UI, widgets, providers
└── main.dart          # Entry point
```

## Setup & Running

1. Ensure you have the latest stable Flutter SDK installed.
2. Clone the repository and run:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Configuration & Environments

The application supports environment variables. By default, it expects:
- `API_BASE_URL` (Defaults to `https://jsonplaceholder.typicode.com`)
- `APP_ENV` (Defaults to `development`)

To run with specific variables:
```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com --dart-define=APP_ENV=production
```

## Quality Assurance

To ensure code quality, run the following commands:

- **Formatting:** `dart format .`
- **Linting:** `flutter analyze`
- **Tests:** `flutter test`

## Architecture Decisions

- **State Management:** Riverpod provides a safe, scalable way to manage state and handle dependency injection.
- **Networking:** Dio is used for robust HTTP requests, including interceptors for headers, errors, and timeouts.
- **Routing:** GoRouter handles deep linking and navigation gracefully.
- **Design System:** Centralized in `lib/app/theme`, supporting dark and light mode out of the box with custom typographies and reusable widgets.
