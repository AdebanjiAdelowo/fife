# FiFe — Build Log & Working Agreement

> **App**: FiFe (Fit & Feline) — *Fitness at Your Fingertips*
> **Stack**: Flutter 3.38.5 / Dart 3.10.4 · DevTools 2.51.1
> **Storage**: 100% local (SharedPreferences) for v1 testing
> **Primary target**: Android (debugging on a Windows host)

This document is the live contract between the human (Michael) and the AI
collaborator. It captures **what's done**, **what's pending**, **the design
decisions we've already made**, and **how to run / hand off the project**.

---

## 1 · Current Status

| Phase | State | Notes |
|---|---|---|
| Read project brief (`FIFE APP.docx`) | ✅ | Feature scope captured below |
| Review reference screens (16 mocks) | ✅ | Visual style locked: dark canvas + electric lime |
| Theme system | ✅ | `lib/core/theme/` |
| Local storage layer | ✅ | `lib/core/storage/local_storage.dart` |
| Session / auth (sha256 hashing) | ✅ | `lib/core/state/session.dart` |
| Welcome screen | ✅ | `lib/features/welcome/` |
| Login + Create Account screens | ✅ | `lib/features/auth/` |
| Dashboard (drawer + bottom nav) | ✅ | `lib/features/dashboard/` |
| Body Progress Map | ✅ | Form, photo cam, table, graph, avatar, compare |
| My Fit Journal | ✅ | First entry pinned, mood tags, history |
| My Fit Schedule | ✅ | Auto schedule, today's tasks, history |
| Check In | ✅ | Workout report + share, diet gallery |
| My Fit Profile | ✅ | Initial body data, BMI, recommended programs |
| Android branding (label = "FiFe") | ✅ | `AndroidManifest.xml` |
| iOS / web / desktop polish | ⏳ | Out of scope for v1 — Android first |
| App icon (replace default) | ⏳ | Use `assets/images/logo.png` via `flutter_launcher_icons` |
| PDF export of Body Progress Map | ⏳ | Pending — `pdf` + `printing` packages |
| AI Coach Fife conversation | ⏳ | Future — currently just static copy |
| Backend / cloud sync | ⏳ | Future — local-only for now |

---

## 2 · Project Structure

```
fife/
├── android/                           # Flutter-generated Android shell
│   └── app/src/main/AndroidManifest.xml  ← label "FiFe", camera/internet perms
├── assets/images/logo.png             # Fit & Feline brand mark
├── lib/
│   ├── main.dart                      # boots LocalStorage + Session, picks Welcome|Dashboard
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # brand palette (lime + charcoal)
│   │   │   ├── app_text_styles.dart   # Plus Jakarta Sans + Playfair Display
│   │   │   └── app_theme.dart         # ThemeData (Material 3, dark)
│   │   ├── state/session.dart         # ChangeNotifier auth + profile updates
│   │   └── storage/local_storage.dart # SharedPreferences-backed JSON store
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── body_measurement.dart
│   │   ├── journal_entry.dart
│   │   ├── schedule_task.dart
│   │   └── workout_report.dart        # + DietGalleryEntry
│   ├── widgets/
│   │   ├── ambient_background.dart    # particle/star backdrop
│   │   ├── fife_card.dart             # standard rounded card + SectionHeader
│   │   ├── fife_logo.dart             # custom-painted F mark + wordmark
│   │   ├── glow_button.dart           # electric-lime CTA + ghost button
│   │   ├── session_scope.dart         # InheritedNotifier → Session
│   │   └── status_chip.dart           # Done / Failed / Pending pill
│   └── features/
│       ├── welcome/welcome_screen.dart
│       ├── auth/{login_screen, create_account_screen}.dart
│       ├── dashboard/dashboard_screen.dart
│       ├── body_progress/{body_progress_screen, body_avatar_painter}.dart
│       ├── journal/journal_screen.dart
│       ├── schedule/schedule_screen.dart
│       ├── check_in/check_in_screen.dart
│       └── profile/profile_screen.dart
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── AGENT.MD                           # ← this file
```

---

## 3 · Brand & Design Decisions

* **Palette** — pure-black canvas (`#0A0B0D`), surfaces in graphite
  (`#14161A`–`#22262C`), CTA glow in electric lime (`#C8F751` → `#B6FF3A`),
  charcoal `#2D2D2D` matched to logo strokes.
* **Type** — Plus Jakarta Sans for the UI, Playfair Display reserved for
  marketing-style displays (echoes the serif "Fit & Feline" wordmark).
  Loaded via `google_fonts` so no font assets needed.
* **Cards** — 22px radius, `AppColors.surfaceSheen` gradient, hairline
  border. Glow variant adds a soft `Color(0x33C8F751)` shadow under the
  CTA buttons. See `widgets/fife_card.dart`.
* **Logo** — drawn with `CustomPainter` (`widgets/fife_logo.dart`) so it
  can recolour and scale crisply on every screen instead of shipping
  multiple raster sizes. The reference PNG is kept for splash/app icon
  use at `assets/images/logo.png`.
* **Backgrounds** — `AmbientBackground` paints randomized particles and
  a corner glow; matches the "starry / dust" backdrop of the references.

---

## 4 · Local Storage Contract (no backend)

| Key | Shape | Notes |
|---|---|---|
| `users.index` | `List<String>` of user ids | All registered FIFers on this device |
| `user.<id>` | JSON `UserProfile` | Includes sha256 password hash |
| `auth.currentUserId` | `String` | Active session pointer |
| `measurements.<userId>` | `List<BodyMeasurement>` JSON | Body Progress Map history |
| `journal.<userId>` | `List<JournalEntry>` JSON | First entry is pinned + read-only |
| `schedule.<userId>.<yyyy-MM-dd>` | `List<ScheduleTask>` | Daily list, default seeded |
| `schedule.<userId>.history` | `List<String>` of date keys | Trimmed to 30 days |
| `workouts.<userId>` | `List<WorkoutReport>` JSON | |
| `diet.<userId>` | `List<DietGalleryEntry>` JSON | Gallery image paths |

Migration path → swap `LocalStorage` for a network-backed implementation
when the backend exists; the rest of the app talks only to that interface.

---

## 5 · Setup & Run (your Flutter machine)

You've already run `flutter create .` once — the platform shells exist.
On future syncs, just do this:

```powershell
# from the project root
flutter pub get
flutter run                     # launches on the connected Android device/emulator
```

If you see version/lock conflicts (e.g. after pulling new dependency
changes from this repo), reset the lockfile:

```powershell
flutter clean
flutter pub get
flutter run
```

### What you may need to do once

1. **Connect an Android device** via USB or start an emulator
   (`flutter emulators --launch <id>`).
2. **Accept Android licenses** if prompted: `flutter doctor --android-licenses`.
3. **(Optional) Replace the default app icon** — the Flutter create
   default is the blue/white "F". To swap in our brand mark:
   ```yaml
   # add to dev_dependencies
   flutter_launcher_icons: ^0.14.4
   # add a top-level config block
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/images/logo.png"
     adaptive_icon_background: "#0A0B0D"
     adaptive_icon_foreground: "assets/images/logo.png"
   ```
   then `dart run flutter_launcher_icons`.

### What you should NOT need to do again
* You do **not** need to re-run `flutter create .` unless the platform
  folders get nuked.
* You do **not** need to delete `lib/main.dart` — it's already wired to
  the new app.

---

## 6 · Testing Plan (for the next pass)

Once you've run it on Android once, walk through:

1. **Welcome → Create Account** — make sure the lime CTA has its glow
   halo and the form validates email + password length.
2. **Dashboard** after sign-up — empty body progress card, profile
   completion 0/10, drawer + bottom nav both reach every section.
3. **Body Progress Map** — fill the form, attach 4 photos, save. Confirm
   the table populates and the avatar/graph appear after the second
   entry.
4. **Journal** — write the first entry; verify it pins to the top and
   becomes read-only on the next visit.
5. **Schedule** — tap a status chip to cycle Done → Failed → Pending.
6. **Check In** — submit a workout, hit Share (system sheet should
   appear). Add a diet photo — gallery tile should show.
7. **Profile** — fill all fields, tap Save. The progress meter on the
   dashboard should jump to 10/10 on return.

---

## 7 · Decisions Log

* **Why SharedPreferences instead of Hive/Isar?** — keeping v1 dependency
  surface tight; SharedPreferences ships with `shared_preferences` and
  needs no codegen. Migrating to Isar later is a single-file swap behind
  the `LocalStorage` interface.
* **Why hash passwords for a local-only app?** — it's a 5-line tax and
  prevents leaking plaintext in the JSON store if the user shares a
  device. Real auth comes when we ship the backend.
* **Why `flutter_lints: ^6.0.0` (the Flutter-create default)?** — keeps
  us aligned with whatever Flutter 3.38 ships. We tightened nothing
  custom in `analysis_options.yaml` to avoid friction.

---

## 8 · Next Suggested Tasks

1. Wire up `flutter_launcher_icons` to publish the Fit & Feline mark as
   the Android launcher icon.
2. Add a splash screen (`flutter_native_splash`) that fades to the
   Welcome page using the same lime glow.
3. Build the Body Progress PDF export (`pdf` + `printing`).
4. Hook a real Coach Fife dialogue (Claude API or another LLM) to the
   journal mood selection — the prompt is the entry text + mood.
5. Add iOS support pass once Android is feature-complete (icon, splash,
   info.plist permissions for camera + photo library).

---

*Updated by Claude (Opus 4.7) on 2026-05-06 during the FiFe scaffold.*
