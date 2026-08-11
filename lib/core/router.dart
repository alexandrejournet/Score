import 'package:go_router/go_router.dart';
import 'models/game.dart';
import '../features/splash/splash_screen.dart';
import '../features/game_detail/game_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/new_game/new_game_screen.dart';
import '../features/game_session/game_session_screen.dart';
import '../features/results/results_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/players_screen.dart';
import '../features/settings/games_screen.dart';
import '../features/settings/groups_screen.dart';
import '../features/settings/statistics_screen.dart';
import '../features/settings/create_game_screen.dart';
import 'shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/games',
              name: 'games',
              builder: (context, state) => const GamesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/players',
              name: 'players',
              builder: (context, state) => const PlayersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'groups',
                  name: 'settings-groups',
                  builder: (context, state) => const GroupsScreen(),
                ),
                GoRoute(
                  path: 'statistics',
                  name: 'statistics',
                  builder: (context, state) => const StatisticsScreen(),
                ),
                GoRoute(
                  path: 'create-game',
                  name: 'create-game',
                  builder: (context, state) => const CreateGameScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/game-detail',
      name: 'game-detail',
      builder: (context, state) {
        final game = state.extra as Game;
        return GameDetailScreen(game: game);
      },
    ),
    GoRoute(
      path: '/new-game',
      name: 'new-game',
      builder: (context, state) => const NewGameScreen(),
    ),
    GoRoute(
      path: '/game-session',
      name: 'game-session',
      builder: (context, state) {
        final gamePlayedId = state.extra as String;
        return GameSessionScreen(gamePlayedId: gamePlayedId);
      },
    ),
    GoRoute(
      path: '/results',
      name: 'results',
      builder: (context, state) {
        final gamePlayedId = state.extra as String;
        return ResultsScreen(gamePlayedId: gamePlayedId);
      },
    ),
  ],
);
