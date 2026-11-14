# THE SYSTEM

**A gamified lifestyle and productivity tracker built with Flutter and Dart.**

THE SYSTEM turns everyday goals into quests. Players log their activities, complete daily objectives, earn experience points (XP), and progress through levels and ranks. The interface uses holographic RPG-inspired panels, luminous borders, and original sound effects.

> **Project status:** University presentation MVP (v0.1). This is a prototype, not a production-ready fitness or health application.

## Features

### Player progression
- Create a local player profile with an awakening flow.
- Begin at **Level 1, Rank E, and 0 XP**.
- Earn XP for completed quests, automatically advancing through levels and ranks.
- View XP progress and completed quest count.

### Daily and personal quests
- **Steps:** Manually log a daily total; 10,000 steps awards **100 XP**.
- **Study:** Log minutes; reaching 120 minutes awards **120 XP**.
- **Nutrition:** Manually enter calories, protein, carbohydrates, and fats. The MVP awards **100 XP** when calories are 1,600–2,600 and protein is at least 120 g.
- **Workout:** Record an exercise and finish a scheduled workout to earn **150 XP**.
- **Personal quests:** Create optional quests worth **50 XP** each.

Quest XP can only be claimed once per day. The nutrition thresholds are **temporary demonstration values**, not personalized dietary guidance.

### Workout tracking
- Choose a **3-day full-body split**, **5-day split**, or **custom training days**.
- Change the workout schedule from the player profile.
- Log exercise names, sets, repetitions, and weights.
- Earn the scheduled workout reward only on a configured training day. Rest-day workouts can still be recorded.

The MVP configures training **days**, not exercise programming for individual days.

### Penalties and history
- When the app reopens or resumes after a date change, it checks whether mandatory quests were missed.
- Complete 15 recovery-study minutes to clear a penalty quest.
- Use a separate labeled **demo penalty** trigger during presentations.
- Inspect activity records using the calendar.

### Interface
- Holographic-style panels with animated entry effects and illuminated details.
- Transparent quest checkboxes with glowing completed states.
- Original sound cues for opening panels, quest completion, leveling up, and penalties.

## Technology stack

| Technology | Purpose |
| --- | --- |
| Flutter and Dart | Cross-platform interface and application logic |
| Material 3 | UI components |
| `shared_preferences` | Local player state and activity history |
| `audioplayers` | Audio playback |
| `google_fonts` | Interface typography |

Data is stored **locally** on the current device/browser. The MVP has no accounts, server, or cloud sync.

## Getting started

### Prerequisites
- Flutter SDK with a compatible Dart SDK
- A configured Flutter development environment
- Chrome for the web demonstration, or another supported configured device

Check your environment:

```bash
flutter doctor
```

Clone, install dependencies, and run:

```bash
git clone https://github.com/TalalNA12/the-system.git
cd the-system
flutter pub get
flutter run -d chrome
```

For a configured Android device, check `flutter devices` and use `flutter run -d <device-id>`. An Android APK requires the Android SDK and build tools; iOS builds require macOS and Xcode.

### Static analysis

```bash
flutter analyze
```

The previous local check reported two informational `curly_braces_in_flow_control_structures` lints, not analyzer errors.

## Live demonstration walkthrough

1. Launch the app and create a player or open the saved profile.
2. Choose or change the workout split.
3. Open **Home** to inspect the player's status, XP, rank, and daily quests.
4. Open **Activity**, log **10,000 steps**, and show the completed quest and earned XP.
5. On a configured training day, log an exercise and finish the workout.
6. Open **Calendar** to inspect the saved daily activity.
7. In **Quests**, trigger the clearly labeled demo penalty, then clear it by logging 15 recovery-study minutes.
8. Refresh the app to demonstrate local persistence.

To demonstrate onboarding again, use a fresh browser profile or clear the site's local storage. **Clearing storage also deletes that browser's saved player progress.**

## Project structure

```text
lib/
  main.dart                  # MVP state, screens, quest and progression logic
  theme/app_theme.dart       # Colors, theme and typography
  widgets/system_window.dart # Holographic windows and border effects
  services/system_audio.dart # Sound-effect playback
assets/sounds/               # Original WAV sound effects
android/                     # Android platform files
ios/                         # iOS platform files
web/                         # Web platform files
```

## Limitations and future work

This version is focused on a reliable live demonstration. Potential additions include health-platform step synchronization, configurable nutrition targets, detailed workout programming, accounts and cloud backup, stronger penalty/date-boundary handling, automated tests, accessibility enhancements, and unlockable mythology-inspired titles.

## Inspiration and assets

The presentation aesthetic is inspired by RPG holographic-system interfaces, including the visual language of *Solo Leveling*. THE SYSTEM is an independent student project and is **not affiliated with or endorsed by** the creators or rights holders of *Solo Leveling*. Sound effects were created for this project.

## Repository

https://github.com/TalalNA12/the-system
