# SCORE — Tabletop Score Tracker

A Flutter app for tracking scores across board games. Designed for speed, simplicity, and a premium tactile feel inspired by physical game components.

## Features

- **Quick scoring** — +/- buttons and direct input for fast score entry
- **Category-based scoring** — Grid layouts, multipliers, and custom categories per game
- **Multi-select mode** — Apply score changes to multiple players at once
- **Game bank** — Pre-configured games with rules, categories, and scoring methods
- **Player management** — Create players with unique colors, organize into groups
- **Statistics** — Track games played, play time, wins per player
- **Dark mode** — Full dark theme support
- **Offline-first** — All data stored locally with automatic persistence
- **i18n** — English and French translations

## Getting Started

### Prerequisites

- Flutter 3.44+ (stable channel)
- Dart 3.12+

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/score.git
cd score

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + theme + localization
├── core/
│   ├── router.dart              # GoRouter configuration
│   ├── shell.dart               # Bottom navigation shell
│   ├── l10n/
│   │   └── app_localizations.dart  # Manual i18n class
│   ├── theme/
│   │   ├── app_colors.dart      # Color palette (light + dark)
│   │   ├── app_spacing.dart     # Spacing tokens
│   │   └── app_theme.dart       # Material 3 theme builder
│   ├── models/
│   │   ├── game.dart            # Game + ScoringCategory
│   │   ├── game_played.dart     # GamePlayed + ScoreEntry + GameStatus
│   │   ├── player.dart          # Player model
│   │   └── group.dart           # Player group model
│   ├── data/repositories/
│   │   ├── game_repository.dart      # Game bank + my games
│   │   ├── game_played_repository.dart
│   │   ├── player_repository.dart
│   │   └── group_repository.dart
│   ├── providers/
│   │   └── app_providers.dart   # Riverpod providers + mutation functions
│   └── services/
│       └── persistence_service.dart  # SharedPreferences persistence
└── features/
    ├── home/                    # Dashboard with In Progress + History
    ├── new_game/                # New game setup screen
    ├── game_session/            # Scoring UI (+/-, categories, multi-select)
    ├── results/                 # Post-game results + ranking
    ├── game_detail/             # Game description + rules
    └── settings/                # Settings, Players, Games, Groups, Statistics
```

## Adding a New Game

See [docs/ADDING_GAMES.md](docs/ADDING_GAMES.md) for a detailed guide.

Quick version:

1. Open `lib/core/data/repositories/game_repository.dart`
2. Add a new `Game(...)` entry to the `defaultGames` list
3. Define categories if using `ScoreType.categories`
4. Restart the app

## Design System

The design system "Tabletop Tactile" is defined in [docs/design.md](docs/design.md). It uses:

- **Colors:** Deep Indigo primary, Mint secondary, Warm Amber tertiary, Soft Clay neutrals
- **Typography:** Bricolage Grotesque for headlines/scores, Plus Jakarta Sans for body
- **Shapes:** Extra-rounded cards (24px), pill-shaped chips
- **Spacing:** 4px baseline grid

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for technical details.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
