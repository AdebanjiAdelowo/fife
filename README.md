# FiFe (Fit & Feline)

A Flutter mobile app for tracking fitness progress: body measurements, workout check-ins, a daily schedule, and a training journal, wrapped in a dark, single-user local-storage experience (no backend required for v1).

Original app concept, design, and the majority of the implementation by Michael Ibukun.
Adebanji Adelowo's contribution to this repository is the iOS Flutter project configuration fix.

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

## Design notes

- **Palette**: pure-black canvas (`#0A0B0D`), graphite surfaces (`#14161A`-`#22262C`), electric-lime
  CTA glow (`#C8F751` to `#B6FF3A`).
- **Type**: Plus Jakarta Sans for UI text, Playfair Display for marketing-style displays, loaded via
  `google_fonts`.
- **Logo**: drawn with `CustomPainter` (`widgets/fife_logo.dart`) so it recolours and scales without
  shipping multiple raster sizes.
- **Local storage schema** (`SharedPreferences`, keyed per user id): `users.index` (registered user
  ids), `user.<id>` (profile, including a SHA-256 password hash), `auth.currentUserId` (active
  session), `measurements.<userId>`, `journal.<userId>`, `schedule.<userId>.<date>` (daily task
  list, seeded by default), `workouts.<userId>`, `diet.<userId>` (gallery image paths). Swapping to
  a network-backed store later is a single-file change behind the `LocalStorage` interface.
- **Why SharedPreferences over Hive/Isar**: keeps the v1 dependency surface small and avoids codegen.
- **Why hash passwords in a local-only app**: avoids leaking plaintext in the JSON store if a device
  is shared; not a substitute for real auth once a backend exists.
