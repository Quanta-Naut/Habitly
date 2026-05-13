# Habit Tracker

Minimal Flutter habit tracker focused on a clean daily flow.

## Current Features

- Daily habit list with quick check-off
- Add habits from the top-right `+` button
- Edit habits from the top-right pencil button
- Delete habits from the pencil sheet with confirmation
- Completion summary under the greeting (`X completed out of Y`)
- Calendar sheet with past and future month browsing
- Strong visual status in calendar:
  - accent-filled dates for completed days
  - red-filled dates for missed days
- Accent color picker in the pencil sheet
- Accent color persists across app restarts
- Local persistence with `shared_preferences`

## Tech

- Flutter
- `shared_preferences` for local storage
- `flutter_local_notifications` and timezone packages already included in the project

## Run

1. Get dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Notes

- Habit data is stored locally on-device.
- The current home experience is the primary app flow.
