# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Initial scaffold of Circle Flutter organization member tracking app.
- Implemented member directory with real-time search bar and life stage filter chips (`All`, `Kids`, `Teens`, `College`, `Working`).
- Added member profile view with stage tags, metadata rows, interests chips, dietary preference tags, and personal notes.
- Added dynamic member creation and editing form with date of birth input, stage-specific fields, and delete functionality.
- Implemented sorted upcoming birthdays list with countdown badges and age calculations.
- Added visual analytics overview dashboard with total count, birthdays this month, life stage progress bars, and top locations.
- Implemented light and dark mode theme switching with `shared_preferences` state persistence.
- Added automated unit and widget test suite (`test/unit/person_test.dart`, `test/widget/directory_screen_test.dart`).
- Configured open-source documentation (`README.md`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`).
