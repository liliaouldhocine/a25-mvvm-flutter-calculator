import 'package:flutter/material.dart';


// Separer du CalculatorViewModel pour respecter MVVM
class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Getter exposer a la View
  bool get isDarkMode => _isDarkMode;

  /// Active / desactive le mode nuit
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
