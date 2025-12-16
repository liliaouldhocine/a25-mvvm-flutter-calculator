import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  // Problem 1 (Q1): Variables were public, need underscore for private
  // Why bad (Q2): MVVM requires encapsulation, View cannot access data directly
  String _display = '0';

  // Problem 5 (Q1): List was mutable, need final and List.unmodifiable()
  // Why bad (Q2): Model data must be immutable to avoid accidental modifications
  final List<String> _history = [];

  // Track current operation to replace it if needed
  String _operation = '';

  // Problem 3 (Q1): No getters, View accessed variables directly
  // Why bad (Q2): Getters allow ViewModel to control data access
  String get display => _display;

  // Problem 5 (Q1): history needs getter returning immutable list
  List<String> get history => List.unmodifiable(_history);

  void inputNumber(String number) {
    // Problem 2 (Q1): Missing notifyListeners() in all methods
    // Why bad (Q2): Without notification, View does not know state changed
    if (_display == '0' || _display == 'Erreur') {
      _display = number;
    } else {
      _display += number;
    }
    notifyListeners();
  }

  // Problem 3 (Q1): No separate setOperation() method
  // Why bad (Q2): Separate method is one responsibility per method
  void setOperation(String operation) {
    // Replace previous operation if it exists
    if (_operation.isNotEmpty && _display.endsWith(_operation)) {
      _display = _display.substring(0, _display.length - 1);
    }
    _display += operation;
    _operation = operation;
    notifyListeners();
  }

  void calculateResult() {
    try {
      double result = 0;

      // Problem 4 (Q1): Only addition, need all 4 operations
      // Why bad (Q2): Incomplete logic is hard to maintain and extend
      if (_display.contains('+')) {
        List<String> parts = _display.split('+');
        result = double.parse(parts[0]) + double.parse(parts[1]);
      } else if (_display.contains('-')) {
        List<String> parts = _display.split('-');
        result = double.parse(parts[0]) - double.parse(parts[1]);
      } else if (_display.contains('×')) {
        List<String> parts = _display.split('×');
        result = double.parse(parts[0]) * double.parse(parts[1]);
      } else if (_display.contains('÷')) {
        List<String> parts = _display.split('÷');
        double divisor = double.parse(parts[1]);
        // Problem 4 (Q1): No division by zero check
        // Why bad (Q2): Incomplete error handling
        if (divisor != 0) {
          result = double.parse(parts[0]) / divisor;
        } else {
          _display = 'Erreur';
          notifyListeners();
          return;
        }
      }

      _display = result.toString();
      _history.add(_display);
      _operation = '';
    } catch (e) {
      // Problem 4 (Q1): No try-catch for error handling
      // Why bad (Q2): Parsing can throw exception, must handle it
      _display = 'Erreur';
    }
    notifyListeners();
  }

  void clearAll() {
    _display = '0';
    _operation = '';
    notifyListeners();
  }
}
