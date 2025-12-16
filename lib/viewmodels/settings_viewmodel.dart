import 'package:flutter/material.dart';

/// ViewModel pour gérer les paramètres de l'application
/// Respecte l'architecture MVVM en séparant la logique des paramètres de l'interface
class SettingsViewModel extends ChangeNotifier {
  // État privé pour le thème sombre
  // Utilisation de l'underscore pour respecter l'encapsulation comme dans CalculatorViewModel
  bool _isDarkTheme = false;

  /// Getter public pour exposer l'état du thème sombre
  /// Permet à la View d'accéder à l'information sans pouvoir la modifier directement
  bool get isDarkTheme => _isDarkTheme;

  /// Getter pour obtenir le ThemeData approprié selon l'état actuel
  /// Centralise la logique de création des thèmes dans le ViewModel
  ThemeData get currentTheme {
    if (_isDarkTheme) {
      // Thème sombre personnalisé pour la calculatrice
      return ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else {
      // Thème clair par défaut (identique au thème original)
      return ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      );
    }
  }

  /// Bascule entre le thème clair et sombre
  /// Méthode publique qui respecte le pattern MVVM en étant la seule façon
  /// de modifier l'état du thème depuis la View
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    
    // Notification essentielle pour informer tous les widgets Consumer
    // que l'état a changé et qu'ils doivent se reconstruire
    notifyListeners();
  }

  /// Définit explicitement le thème (pour des cas d'usage futurs)
  /// Peut être utile pour sauvegarder/restaurer les préférences utilisateur
  void setTheme(bool isDark) {
    if (_isDarkTheme != isDark) {
      _isDarkTheme = isDark;
      notifyListeners();
    }
  }
}