# Contributing to SCORE

Thank you for your interest in contributing! This guide will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/score.git`
3. Create a branch: `git checkout -b feature/my-feature`
4. Install dependencies: `flutter pub get`
5. Run the app: `flutter run`

## Development Guidelines

### Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` before committing — **zero warnings/errors required**
- Run tests: `flutter test`
- No comments unless absolutely necessary
- Prefer `final` over `var`
- Use `const` constructors where possible

### Architecture

- **Models** in `core/models/` — pure Dart, no Flutter dependencies except `Color`
- **Repositories** in `core/data/repositories/` — in-memory storage, no side effects
- **Providers** in `core/providers/` — Riverpod, one source of truth per data type
- **Screens** in `features/` — one folder per screen, widgets in `widgets/` subfolder

### Adding a Game

See [docs/ADDING_GAMES.md](docs/ADDING_GAMES.md).

### Adding a Feature

1. Check the [Roadmap](docs/Roadmap_Application_Scoring_Jeux.md) for planned features
2. Open an issue to discuss your idea
3. Implement in a feature branch
4. Write tests if applicable
5. Submit a pull request

### Translations

The app supports English and French via `AppLocalizations` in `core/l10n/app_localizations.dart`. To add a language:

1. Add a new `_t()` call with the translation
2. Add the locale to `supportedLocales` in `app.dart`
3. Test with `flutter run --locale xx`

### Design

Follow the "Tabletop Tactile" design system in [docs/design.md](docs/design.md):

- Use the defined color tokens, not hardcoded colors
- Use the 4px spacing grid
- Use Bricolage Grotesque for headlines/scores, Plus Jakarta Sans for body
- Cards use 24px border radius, buttons use 16px

## Pull Request Process

1. Ensure `flutter analyze` passes with no issues
2. Ensure `flutter test` passes
3. Update documentation if needed
4. Describe what your PR does and why
5. Link to any related issues

## Reporting Bugs

- Use GitHub Issues
- Include steps to reproduce
- Include Flutter version (`flutter --version`)
- Include device/platform info
- Screenshots or screen recordings are helpful

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
