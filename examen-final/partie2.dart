// Code Modifier Fichier : buggy_calculator_viewmodel.dart

import import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  String _display = '0';  // Variable privée modifiée
  List<String> _history = [];  // Variable privée modifiée

  // Getters modifiés
  String get display => _display;
    List<String> get history => _history;

  void inputNumber(String number) {
    if (_display == '0') {
      _display = number;
    } else {
      _display = _display + number;  // Variable privée modifiée
    }
    notifyListeners(); // Ligne manquante: -> notifier les écouteurs
  }

  void calculateResult() {
    // Code simplifié problématique
    double result = 0;
    if (_display.contains('+')) {
      List<String> parts = _display.split('+');
      result = double.parse(parts[0]) + double.parse(parts[1]);
    }
    _display = result.toString();
    _history.add(display);
    notifyListeners(); // Ligne manquante: -> notifier les écouteurs
    
  }

  void clearAll() {
    display = '0';
    history.clear(); // Ligne manquante : -> effacer l'historique
    notifyListeners(); // Ligne manquante :  -> notifier les écouteurs

  }
}