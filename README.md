# Team Workspace

Team Workspace is a Flutter application for managing tasks with authentication, routing, and a clean feature-based structure. The app is organized around a small layered architecture with shared core utilities, feature modules, and environment-based configuration.

## Setup instructions

1. Install Flutter SDK 3.5+ and ensure the Flutter toolchain is available on your PATH.
2. From the project root, install dependencies:
   - `flutter pub get`
3. Create or update the environment file used by the app:
   - Copy `.env.example` to `.env` if needed and adjust values such as `DEV_BASE_URL`, `PROD_BASE_URL`, and `TASKS_ENDPOINT`.
4. Run the app with one of the supported entrypoints:
   - Development: `flutter run -t lib/main_dev.dart`
   - Production: `flutter run -t lib/main_prod.dart --release`
5. For tests:
   - `flutter test`

## Architecture overview

The application follows a simple feature-first structure:

- `lib/core` contains shared infrastructure such as routing, DI, networking, theme, environment config, and reusable widgets.
- `lib/features` contains domain-driven feature modules:
  - `auth` for authentication flow and state
  - `tasks` for task list, detail, edit, and creation flows
- `lib/bootstrap.dart` initializes shared services before the app starts.
- `lib/app.dart` wires the app shell, router, and global providers together.

## Packages used

The project uses the following main packages:

- `flutter_bloc` and `bloc` for state management
- `get_it` for dependency injection
- `go_router` for navigation
- `dio` for HTTP networking
- `firebase_core` and `firebase_auth` for authentication services
- `hive` and `shared_preferences` for local persistence
- `connectivity_plus` for connectivity awareness
- `dartz` and `equatable` for functional patterns and value equality
- `flutter_dotenv` for environment configuration
- `intl` for formatting helpers

## Assumptions made

- The app uses a demo or placeholder backend base URL by default when environment values are not supplied.
- Authentication and task APIs are expected to be available through the configured endpoints.
- Environment values are loaded from a local `.env` file during startup.
- The current implementation targets a mobile-first Flutter experience and is structured to support further expansion into additional features or platforms.
