# Habitly Play Store Deck

## App Overview

- App name: Habitly
- Category suggestion: Productivity
- Secondary category suggestion: Health & Fitness
- Current version: 0.1.0
- Platform: Flutter app with Android, iOS, web, desktop targets
- Positioning: A minimal habit tracker for quick daily check-ins without accounts, sync, or clutter

## One-Line Pitch

Habitly helps users build consistency with a clean daily habit tracker, fast check-offs, simple reminders, and progress insights.

## Short Description

Track habits daily with a clean, minimal routine checker.

## Full Description

Habitly is a simple habit tracker built for people who want a clean daily routine without noise, accounts, or complicated setup.

Create habits in seconds, check them off with one tap, and keep momentum with a focused daily flow. Habitly keeps your progress easy to understand with completion summaries, a visual habit calendar, streak tracking, and lightweight insights.

What you can do in Habitly:

- Add, edit, and delete habits quickly
- Mark habits complete with a single tap
- Review daily progress at a glance
- View a habit calendar with completed and missed days
- Track streaks and overall consistency
- Customize the app accent color
- Keep everything stored locally on your device
- Use reminders for habit check-ins

Why users may like Habitly:

- Minimal interface
- Fast daily workflow
- No account required
- No cloud setup
- Clear progress feedback
- Designed for consistency, not complexity

Habitly is ideal for routines like reading, stretching, water intake, workouts, meditation, sleep goals, and other daily habits.

## Keyword Ideas

- habit tracker
- daily habits
- streak tracker
- routine planner
- productivity app
- goal tracker
- self improvement
- daily routine
- consistency tracker
- minimalist habit app

## Core Features In This Build

- Daily habit list with quick check-off
- Add and edit habits
- Delete habits with confirmation
- Completion summary on the home screen
- Calendar view for completed and missed days
- Accent color customization
- Local persistence using `shared_preferences`
- Local notifications for reminders
- Weekly and monthly insight views exist in the codebase, but confirm the final navigation exposure before screenshots and release copy

## Target Audience

- Users who want a simple habit tracker
- Students building routines
- Professionals tracking consistent daily actions
- People who prefer privacy and local-only apps
- Users who dislike account creation and bloated wellness apps

## Store Listing Visual Direction

- Tone: calm, minimal, friendly
- Primary colors: white, soft cream, green, warm accent tones
- Icon direction: sprout in smiling pot
- Screenshot style: clean UI, lots of whitespace, highlight one feature per image

## Screenshot Copy Suggestions

### Screenshot 1

- Headline: Build habits without the clutter
- Support line: A clean daily routine tracker with one-tap check-ins

### Screenshot 2

- Headline: Stay consistent every day
- Support line: Track completed habits and see your progress clearly

### Screenshot 3

- Headline: See wins and missed days
- Support line: Use the calendar view to understand your routine over time

### Screenshot 4

- Headline: Keep your streak going
- Support line: Spot momentum quickly with visual progress and streaks

### Screenshot 5

- Headline: Make it feel like yours
- Support line: Personalize the app with a simple accent color picker

## Promotional Text Ideas

- Minimal habit tracking for real daily consistency.
- Build routines with a clean tracker, reminders, and simple progress views.
- A lightweight habit tracker with fast check-ins and no account required.

## Release Notes Template

### Version 0.1.0

- First public release of Habitly
- Create, edit, and manage daily habits
- Check off habits with a clean daily workflow
- View habit history in the calendar
- Set reminders and personalize the app accent color

## Play Store Listing Fields To Prepare

- App name: Habitly
- Short description
- Full description
- App icon: complete
- Feature graphic: still needed
- Phone screenshots: still needed
- Privacy Policy URL: still needed
- Support email: still needed
- Website or landing page: optional but recommended

## Data Safety Draft

Based on the current codebase, this app appears to:

- Store habit data locally on device
- Not require login or account creation
- Not send user habit data to a backend
- Use local notifications for reminders

Likely Data Safety direction:

- Data collected: None, if no analytics, crash reporting, ads SDKs, or backend services are added before release
- Data shared: None
- Security handling: Local-only storage on device

Important: Re-check the final Android build dependencies before submitting. If analytics, ads, crash reporting, cloud sync, or external APIs are added later, this section must be updated.

## Permissions / Disclosure Notes

- Notifications: explain clearly that reminders are optional and used only for scheduled habit prompts
- If exact alarm behavior is introduced later at the Android manifest level, add an in-app explanation before release

## Privacy Policy Talking Points

Your privacy policy can likely state:

- Habitly stores habit and completion data locally on your device
- Habitly does not require account creation
- Habitly does not sell personal data
- Habitly does not share habit data with third parties
- Notification permissions are used only to deliver reminder alerts selected by the user

## Pre-Launch Checklist

- Verify the app name displays as Habitly on Android, iOS, web, macOS, and Windows
- Test the new launcher icon on Android and iOS home screens
- Confirm startup screen background is white
- Verify add, edit, delete, and daily check-off flows
- Verify local notification permissions and reminder delivery
- Confirm no debug banners or placeholder text remain
- Create final screenshots from the production build
- Prepare a privacy policy URL
- Test on at least one real Android device before Play Store submission

## Optional Improvements Before Publishing

- Wire the insights and profile flows into the primary navigation if they are meant to be public features
- Add onboarding or a first-run empty state tutorial
- Add export/backup if long-term retention matters
- Add a clear privacy policy screen inside the app
- Add a Play Store feature graphic sized for current Google Play requirements
