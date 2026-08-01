# Adding a New Game

This guide explains how to add a new board game to SCORE.

## Quick Start

All games are defined in `lib/core/data/repositories/game_repository.dart` in the `defaultGames` list.

```dart
Game(
  id: 'my-game',           // Unique identifier (lowercase, hyphens)
  name: 'My Game',         // Display name
  minPlayers: 2,
  maxPlayers: 6,
  color: Color(0xFF3498DB),
  icon: '🎲',              // Emoji icon
  scoreType: ScoreType.points,  // or ScoreType.categories
  rules: 'Description of the rules...',
),
```

## Score Types

### Simple Points (`ScoreType.points`)

For games where each player has a single score that goes up or down.

```dart
Game(
  id: 'flip7',
  name: 'Flip 7',
  scoreType: ScoreType.points,
  minPlayers: 2,
  maxPlayers: 99,
  // ...
)
```

The session screen shows +/- buttons and a direct input dialog.

### Categories (`ScoreType.categories`)

For games with multiple scoring categories. Each category is a `ScoringCategory`:

```dart
ScoringCategory(
  label: 'Plazas',              // Display name
  description: 'Blue districts', // Optional description
  maxValue: 99,                  // Optional max value for progress bar
  defaultValue: 0,               // Initial value
  hasMultiplier: false,          // Show × multiplier input?
)
```

Example — Akropolis:

```dart
Game(
  id: 'akropolis',
  name: 'Akropolis',
  scoreType: ScoreType.categories,
  categories: const [
    ScoringCategory(label: 'Plazas', description: 'Blue districts', maxValue: 99, hasMultiplier: true),
    ScoringCategory(label: 'Gardens', description: 'Green districts', maxValue: 99, hasMultiplier: true),
    ScoringCategory(label: 'Barracks', description: 'Red districts', maxValue: 99, hasMultiplier: true),
    ScoringCategory(label: 'Temples', description: 'Purple districts', maxValue: 99, hasMultiplier: true),
    ScoringCategory(label: 'Market', description: 'Yellow districts', maxValue: 99, hasMultiplier: true),
    ScoringCategory(label: 'Architect bonus', description: 'Special tiles', maxValue: 50),
  ],
)
```

### Grid Categories (Château Combo style)

For games that use a grid (like a 3×3 card layout). Use category labels in the format `Carte X,Y`:

```dart
categories: const [
  ScoringCategory(label: 'Carte 1,1'),
  ScoringCategory(label: 'Carte 1,2'),
  ScoringCategory(label: 'Carte 1,3'),
  ScoringCategory(label: 'Carte 2,1'),
  ScoringCategory(label: 'Carte 2,2'),
  ScoringCategory(label: 'Carte 2,3'),
  ScoringCategory(label: 'Carte 3,1'),
  ScoringCategory(label: 'Carte 3,2'),
  ScoringCategory(label: 'Carte 3,3'),
  ScoringCategory(label: 'Keys remaining', description: 'Number of keys'),
],
```

The UI automatically renders grid categories as a square grid, and non-grid categories as regular rows below.

## Game Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (use lowercase + hyphens) |
| `name` | `String` | Display name |
| `scoreType` | `ScoreType` | `points` or `categories` |
| `minPlayers` | `int` | Minimum number of players |
| `maxPlayers` | `int` | Maximum number of players |
| `icon` | `String?` | Emoji icon |
| `color` | `Color` | Theme color for the game card |
| `isFavorite` | `bool` | Initial favorite state |
| `isCustom` | `bool` | `true` for user-created games |
| `allowMultiSelect` | `bool` | Show multi-select mode in session (e.g., Mille Sabords) |
| `categories` | `List<ScoringCategory>` | Scoring categories |
| `rules` | `String?` | Rules text shown in game detail |

## Localization

Game names and rules are currently not localized (they're defined directly in Dart). If you want to support multiple languages, you can use the `AppLocalizations` class:

```dart
// In app_localizations.dart
String get flip7Name => _t('Flip 7', 'Flip 7');
String get flip7Rules => _t(
  'Draw cards one by one. If you draw a duplicate, you bust.',
  'Piochez des cartes une par une. Si vous piochez un doublon, vous perdez tout.',
);
```

Then reference it in the Game definition. However, since game names are displayed in multiple places (tabs, cards, history), keeping them as plain strings is simpler.

## Testing

After adding a game:

1. Hot restart the app (`R` in terminal)
2. Go to **Jeux** → verify it appears in the game bank
3. Add it to **Mes jeux**
4. Create a new game session → verify scoring works
5. Finish the game → verify results and statistics
