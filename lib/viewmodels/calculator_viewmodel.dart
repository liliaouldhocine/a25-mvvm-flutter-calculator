import 'package:flutter/material.dart';
import '../models/calculation.dart';

class CalculatorViewModel extends ChangeNotifier {
  String _display = '0';
  String _currentInput = '';
  String _pendingOperation = '';
  double _storedValue = 0;
  final List<Calculation> _history = [];

  String get display => _display;
  List<Calculation> get history => List.unmodifiable(_history);

  void inputNumber(String number) {
    if (_display == '0' || _pendingOperation.isNotEmpty) {
      _display = number;
    } else {
      _display += number;
    }
    _currentInput = _display;
    notifyListeners();
  }

  void inputDecimal() {
    if (!_display.contains('.')) {
      _display += '.';
      _currentInput = _display;
      notifyListeners();
    }
  }

//Ajout de la fonction pourcentage
void calculatePercentage() {
  // Si on a un nombre dans le _storedValue et un nombre dans le _currentInput, calcule le pourcentage
  if (_storedValue != 0 && _currentInput.isNotEmpty) {
    try {
      final currentValue = double.parse(_currentInput);
      final percentage = currentValue / 100;
      final result = _storedValue * percentage;
      
      _display = result.toString();
      _currentInput = _display;
      notifyListeners();
    } catch (e) {
      _display = 'Erreur';
      notifyListeners();
    }
  } else if (_currentInput.isNotEmpty) {
    // S'il y a seulement un nombre dans le _currentInput, on calcule le pourcentage de ce nombre
    try {
      final currentValue = double.parse(_currentInput);
      final result = currentValue / 100;
      
      _display = result.toString();
      _currentInput = _display;
      notifyListeners();
    } catch (e) {
      _display = 'Erreur';
      notifyListeners();
    }
  }
}


  void setOperation(String operation) {
    if (_currentInput.isNotEmpty) {
      _storedValue = double.parse(_currentInput);
    }
    _pendingOperation = operation;
    _currentInput = '';
    _display = '0';
    notifyListeners();
  }

  void calculateResult() {
    if (_pendingOperation.isEmpty || _currentInput.isEmpty) return;

    final currentValue = double.parse(_currentInput);
    double result = 0;

    switch (_pendingOperation) {
      case '+':
        result = _storedValue + currentValue;
        break;
      case '-':
        result = _storedValue - currentValue;
        break;
      case '×':
        result = _storedValue * currentValue;
        break;
      case '÷':
        if (currentValue != 0) {
          result = _storedValue / currentValue;
        } else {
          _display = 'Erreur';
          _resetCalculator();
          notifyListeners();
          return;
        }
        break;
    }

    final calculation = Calculation(
      expression: '$_storedValue $_pendingOperation $currentValue',
      result: result,
      timestamp: DateTime.now(),
    );

    _history.add(calculation);
    _display = result.toString();
    _resetCalculator();
    notifyListeners();
  }

  void clear() {
    _display = '0';
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
    notifyListeners();
  }

  void deleteLast() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
    _currentInput = _display;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void _resetCalculator() {
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
  }
}
