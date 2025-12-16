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

  void setOperation(String operation) {
    if (_currentInput.isNotEmpty) {
      _storedValue = double.parse(_currentInput);
    }
    _pendingOperation = operation;
    _currentInput = '';
    _display = '0';
    notifyListeners();
  }
  
  void calculatePercentage() {
    final inputToUse = _currentInput.isNotEmpty ? _currentInput : _display;
    if (inputToUse.isEmpty || inputToUse == '0') return;
    
    try {
      final value = double.parse(inputToUse);
      final percentage = value / 100;
      
      _display = percentage.toString();
      _currentInput = _display;
      notifyListeners();
    } on FormatException {
      _display = 'Erreur';
      notifyListeners();
    }
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
		// case '%':
		// 	result = _storedValue * currentValue / 100;
		// 	break;
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
