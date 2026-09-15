# FiFe (Fit & Feline)

A Flutter mobile app for tracking fitness progress: body measurements, workout check-ins, a daily schedule, and a training journal, wrapped in a dark, single-user local-storage experience (no backend required for v1).

## Features

- **Auth**: local sign-up and login (SHA-256 hashed credentials via `crypto`), session persisted with `shared_preferences`
- **Dashboard**: drawer and bottom navigation across the app's screens
- **Body Progress Map**: measurement entry form, progress photos, history table, and a chart (via `fl_chart`) with a before/after comparison view
- **Fit Journal**: journal entries with mood tags and history
- **Fit Schedule**: auto-generated schedule with a daily task list and history
- **Check In**: workout report entry with sharing (via `share_plus`) and a diet photo gallery
- **Fit Profile**: initial body data, BMI calculation, and recommended programs

## Tech stack

Flutter (Dart SDK `^3.10.4`), Material 3 dark theme, `shared_preferences` for local persistence, `fl_chart` for charts, `google_fonts` for typography, `image_picker` for photo capture, `share_plus` for sharing check-in reports.

Currently targets Android as the primary platform; iOS, web, and desktop build files are present but unpolished.

## Getting started

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK (3.38+) with Dart 3.10+.

## Project structure

```
lib/
├── core/
│   ├── theme/      # colors, text styles, ThemeData
│   ├── state/      # Session (auth + profile state)
│   └── storage/    # SharedPreferences-backed local store
├── features/       # auth, dashboard, body_progress, journal, schedule, check_in, profile, welcome
├── models/         # UserProfile, BodyMeasurement, JournalEntry, ScheduleTask, WorkoutReport
└── widgets/        # shared UI components
```
