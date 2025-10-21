// lib/storage/storage_helper.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  // Keys
  static const String themeKey = 'theme_v1';
  static const String tasksKey = 'tasks_v1';

  // THEME
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(themeKey);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
    await prefs.setString(themeKey, value);
  }

  // TASKS
  static Future<List<Map<String, dynamic>>> loadTasksRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(tasksKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
      return <Map<String, dynamic>>[];
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Saves tasks by accepting a List<Map>
  static Future<void> saveTasksRaw(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(list);
    await prefs.setString(tasksKey, payload);
  }
}
