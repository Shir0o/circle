# Circle · Organization Member Tracking App

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Circle** is a modern, responsive cross-platform member tracking application built with Flutter. It allows organizations, community groups, and teams to track members across life stages (`Kids`, `Teens`, `College`, `Working`), celebrate upcoming birthdays, manage dietary preferences and contact connections, and view organizational demographics.

---

## ✨ Features

- 👥 **Member Directory**: Fast real-time search, life stage filter chips (`All`, `Kids`, `Teens`, `College`, `Working`), and detailed member cards.
- 👤 **Detailed Profiles**: Full view of education (Year/Major/School), career, birthday, location, interests, dietary preferences, and personal notes.
- ✏️ **Dynamic Member Form**: Add or edit member details with stage-specific inputs, date picker, and tag management.
- 🎂 **Upcoming Birthdays**: Sorted list of member birthdays with days until celebration, turning age calculations, and highlight indicators for birthdays within 30 days.
- 📊 **Demographics Overview**: Visual statistics including total member count, birthdays in the current month, life stage distribution progress bars, and top member locations.
- 🌗 **Light & Dark Mode**: Modern warm light theme and rich dark theme with persistent preference saving.
- 💾 **Local Persistence**: Automatic JSON state storage via `shared_preferences` seeded with default member data.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>=3.44.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.12.0`)

### Installation & Execution

1. Clone the repository:
   ```bash
   git clone https://github.com/Shir0o/circle.git
   cd circle
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run locally:
   ```bash
   # Run on macOS desktop
   flutter run -d macos

   # Run on Chrome web
   flutter run -d chrome
   ```

---

## 🧪 Testing

Run the full automated test suite (unit and widget tests):

```bash
flutter test
```

Analyze code quality:

```bash
flutter analyze
```

---

## 🏗️ Architecture

```
lib/
├── main.dart                   # Application entry point & Provider initialization
├── models/
│   └── person.dart             # Person data model, life stage metadata, calculated properties
├── providers/
│   └── people_provider.dart    # Central state management & SharedPreferences persistence
├── theme/
│   └── app_theme.dart          # Light and dark color palettes, typography & component themes
└── screens/
    ├── main_screen.dart        # Navigation scaffold & theme switcher
    ├── directory_screen.dart   # Member list, search bar & filter chips
    ├── profile_screen.dart     # Member detail view
    ├── form_screen.dart        # Add/edit member form
    ├── birthdays_screen.dart   # Sorted birthday celebrations & countdown badges
    └── overview_screen.dart    # Visual analytics & location demographics dashboard
```

---

## 🤝 Contributing

Contributions are welcome! Please review [CONTRIBUTING.md](CONTRIBUTING.md) for details on code standards and submitting pull requests.

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
