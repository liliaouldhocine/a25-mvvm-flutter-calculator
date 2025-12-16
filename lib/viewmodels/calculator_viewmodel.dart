import 'package:flutter/material.dart';
import '../models/calculation.dart';

class CalculatorViewModel extends ChangeNotifier {
  // Variables existantes
  String _display = '0';
  String _currentInput = '';
  String _pendingOperation = '';
  double _storedValue = 0;
  final List<Calculation> _history = [];
  
  // NOUVELLE VARIABLE POUR LA MÉMOIRE
  double? _memory;
  
  // Getters existants
  String get display => _display;
  List<Calculation> get history => List.unmodifiable(_history);
  
  // NOUVEAUX GETTERS POUR LA MÉMOIRE
  double? get memory => _memory;
  bool get hasMemory => _memory != null;
  String get memoryDisplay {
    if (_memory == null) return '';
    return 'M=${_formatMemory(_memory!)}';
  }
  
  // ====================
  // MÉTHODES EXISTANTES
  // ====================
  
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
    _display = _formatNumber(result);
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
  
  // ====================
  // NOUVELLES MÉTHODES POUR LA MÉMOIRE
  // ====================
  
  /// Ajoute la valeur affichée à la mémoire
  void addToMemory() {
    try {
      final currentValue = double.tryParse(_display);
      
      if (currentValue != null) {
        // Si la mémoire est nulle, on l'initialise à la valeur courante
        // Sinon, on additionne
        _memory = (_memory ?? 0) + currentValue;
        
        // Ajouter une entrée à l'historique pour le suivi
        final memoryCalculation = Calculation(
          expression: 'M+ : $_display',
          result: _memory!,
          timestamp: DateTime.now(),
        );
        _history.add(memoryCalculation);
        
        notifyListeners();
      }
    } catch (e) {
      _display = 'Erreur';
      notifyListeners();
    }
  }
  
  /// Rappelle la valeur en mémoire et l'affiche
  void recallMemory() {
    if (_memory != null) {
      _display = _formatNumber(_memory!);
      _currentInput = _display;
      
      notifyListeners();
    }
  }
  
  /// Efface la mémoire
  void clearMemory() {
    _memory = null;
    notifyListeners();
  }
  
  /// Soustrait la valeur affichée de la mémoire (fonction bonus)
  void subtractFromMemory() {
    try {
      final currentValue = double.tryParse(_display);
      
      if (currentValue != null) {
        _memory = (_memory ?? 0) - currentValue;
        notifyListeners();
      }
    } catch (e) {
      _display = 'Erreur';
      notifyListeners();
    }
  }
  
  
  
  void _resetCalculator() {
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
  }
  
  String _formatNumber(double number) {
    
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
    }
  }
  
  String _formatMemory(double memory) {
    if (memory % 1 == 0) {
      return memory.toInt().toString();
    } else {
      
      return memory.toStringAsFixed(2);
    }
  }
}