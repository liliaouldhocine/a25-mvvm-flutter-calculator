import 'package:flutter/material.dart';

/// SettingsViewModel
/// - Responsabilité unique: gérer l'état des paramètres d'application (ici le thème).
/// - Expose des getters pour l'UI (MVVM: la vue lit via getters, ne lit pas les champs privés).
/// - Notifie les observateurs via notifyListeners() quand l'état change.
class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Getter public pour l'état du thème (utilisé par MaterialApp & SettingsScreen).
  bool get isDarkMode => _isDarkMode;

  /// Basculer le mode (clarity: API unique et explicite).
  void toggleDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }

  /// Optionnel: exposition du ThemeMode pour simplifier l'usage côté MaterialApp.
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
