import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/group.dart';
import '../models/game_played.dart';

class PersistenceService {
  static const _gamesKey = 'games';
  static const _playersKey = 'players';
  static const _groupsKey = 'groups';
  static const _gamePlayedKey = 'game_played';
  static const _themeKey = 'theme_mode';
  static const _hapticKey = 'haptic_feedback_enabled';
  static const _myGameIdsKey = 'my_game_ids';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static ThemeMode loadThemeMode() {
    final value = _prefs?.getString(_themeKey);
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs?.setString(_themeKey, mode.name);
  }

  static bool loadHapticEnabled() {
    return _prefs?.getBool(_hapticKey) ?? true;
  }

  static Future<void> saveHapticEnabled(bool enabled) async {
    await _prefs?.setBool(_hapticKey, enabled);
  }

  static List<Game> loadCustomGames() {
    return _parseList(_prefs?.getString(_gamesKey), Game.fromJson);
  }

  static List<Player> loadPlayers() {
    return _parseList(_prefs?.getString(_playersKey), Player.fromJson);
  }

  static List<Group> loadGroups() {
    return _parseList(_prefs?.getString(_groupsKey), Group.fromJson);
  }

  static List<GamePlayed> loadGamePlayed() {
    return _parseList(_prefs?.getString(_gamePlayedKey), GamePlayed.fromJson);
  }

  static Set<String> loadMyGameIds() {
    final list = _prefs?.getStringList(_myGameIdsKey);
    if (list == null) return {};
    return Set<String>.from(list);
  }

  static Future<void> saveAll({
    required List<Game> customGames,
    required List<Player> players,
    required List<Group> groups,
    required List<GamePlayed> gamePlayed,
    required Set<String> myGameIds,
  }) async {
    await _prefs?.setString(_gamesKey, jsonEncode(customGames.map((g) => g.toJson()).toList()));
    await _prefs?.setString(_playersKey, jsonEncode(players.map((p) => p.toJson()).toList()));
    await _prefs?.setString(_groupsKey, jsonEncode(groups.map((g) => g.toJson()).toList()));
    await _prefs?.setString(_gamePlayedKey, jsonEncode(gamePlayed.map((g) => g.toJson()).toList()));
    await _prefs?.setStringList(_myGameIdsKey, myGameIds.toList());
  }

  static List<T> _parseList<T>(String? json, T Function(Map<String, dynamic>) fromJson) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
