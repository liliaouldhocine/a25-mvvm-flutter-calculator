import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  String display = '0'; // Ligne modifiée
  List<String> history = []; // Ligne modifiée

  void inputNumber(String number) {
    if (display == '0') {
      display = number;
    } else {
      display = display + number; // Ligne modifiée
    }
    // Ligne manquante
  }

  void calculateResult() {
    // Code simplifié problématique
    double result = 0;
    if (display.contains('+')) {
      List<String> parts = display.split('+');
      result = double.parse(parts[0]) + double.parse(parts[1]);
    }
    display = result.toString();
    history.add(display);
    // Ligne manquante
  }

  void clearAll() {
    display = '0';
    // Ligne manquante
  }
}
