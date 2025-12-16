import 'package:flutter/material.dart';

/// SettingsViewModel - Gestion du thème de l'application (Mode Sombre/Clair)

class SettingsViewModel extends ChangeNotifier {
  // ÉTAT PRIVÉ
  // L'état du mode sombre est privé pour respecter l'encapsulation MVVM.
  bool _isDarkMode = false;

  // GETTERS PUBLICS
  /// Getter pour exposer l'état du mode sombre à la View.
  bool get isDarkMode => _isDarkMode;

  /// Getter pour obtenir le ThemeMode actuel.
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // MÉTHODES PUBLIQUES
  /// Active ou désactive le mode sombre.
  void setDarkMode(bool value) {
    _isDarkMode = value;
    // Notification à tous les widgets Consumer pour reconstruire l'UI
    notifyListeners();
  }

  /// Bascule l'état du mode sombre (toggle).
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
