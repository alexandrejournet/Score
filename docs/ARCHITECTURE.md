# Architecture

## Overview

SCORE follows a **feature-first** architecture with Riverpod for state management and GoRouter for navigation.

## Layers

### Models (`core/models/`)

Pure Dart classes with JSON serialization. No framework dependencies except `Color`.

- `Game` — Game definition with scoring categories
- `Player` — Player with name and color
- `Group` — Named group of player IDs
- `GamePlayed` — A game session with scores, history, and status
- `ScoreEntry` — A single score snapshot in history

### Repositories (`core/data/repositories/`)

In-memory data stores with CRUD operations. They don't notify listeners directly — Riverpod providers handle that.

```
GameRepository
  ├── defaultGames (built-in)
  ├── _customGames (user-created)
  ├── _myGameIds (games added to "my games")
  └── toggleFavorite(), addToMyGames(), removeFromMyGames()
```

### Providers (`core/providers/`)

Riverpod providers that expose repository data. The key pattern:

```dart
final gameDataVersionProvider = StateProvider<int>((ref) => 0);

final allGamesProvider = Provider<List<Game>>((ref) {
  ref.watch(gameDataVersionProvider);  // triggers rebuild on changes
  return ref.read(gameRepositoryProvider).all;
});
```

**Why this pattern?** The repositories are mutable objects inside `Provider<>`. Watching the provider itself doesn't trigger rebuilds because the object reference doesn't change. The `gameDataVersionProvider` acts as a change notification — every mutation calls `bumpGameVersion(ref)` to increment it, which triggers `ref.watch()` in dependent providers.

### Mutations

All data mutations go through top-level functions in `app_providers.dart`:

```dart
void addPlayer(WidgetRef ref, Player player) {
  ref.read(playerRepositoryProvider).add(player);
  ref.invalidate(allPlayersProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}
```

Pattern: mutate → invalidate → bump version → persist.

### Persistence (`core/services/`)

`PersistenceService` wraps `SharedPreferences` with JSON serialization. Called after every mutation via `_saveData(ref)`.

### Navigation (`core/router.dart`)

GoRouter with a `StatefulShellRoute` for the bottom navigation (Dashboard, Games, Players, Settings). Game session and results are top-level routes pushed on top of the shell.

### Localization (`core/l10n/`)

Manual `AppLocalizations` class with a `LocalizationsDelegate`. Supports English and French. The locale is detected from the device settings.

## State Flow

```
User action
  → mutation function (addPlayer, updateScore, etc.)
    → repository.update()
    → ref.invalidate(provider)
    → bumpGameVersion(ref)
    → _saveData(ref) → SharedPreferences
  → provider watches version → rebuilds UI
```

## Game Session Scoring

The game session screen adapts based on the game's `scoreType`:

- **`ScoreType.points`** — Simple +/- buttons + direct input dialog
- **`ScoreType.categories`** — Category grid with text fields, multipliers, and totals
- **`allowMultiSelect`** — Checkbox mode for batch score changes (e.g., Mille Sabords)

Grid categories (labels matching `Carte X,Y`) are rendered as a square grid. Other categories are rendered as rows.

## Design System

The app theme is built on Material 3 with a custom color palette. The `AppTheme` class generates both light and dark themes from the same color tokens. Typography uses Google Fonts (Bricolage Grotesque for headlines, Plus Jakarta Sans for body).
