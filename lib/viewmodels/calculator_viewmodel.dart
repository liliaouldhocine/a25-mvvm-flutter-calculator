import 'package:flutter/material.dart';
import '../models/calculation.dart';

class CalculatorViewModel extends ChangeNotifier {
  String _display = '0';
  String _currentInput = '';
  String _pendingOperation = '';
  double _storedValue = 0;
  final List<Calculation> _history = [];
  
  // Nouvel état pour le pourcentage
  bool _percentageApplied = false;
  double _lastPercentageValue = 0;

  // ============================================================
  // GETTERS - Exposent les états privés à la View
  // ============================================================
  
  String get display => _display;
  List<Calculation> get history => List.unmodifiable(_history);
  
  /// Getter pour indiquer si un pourcentage a été appliqué
  /// Permet à la View de réagir visuellement (ex: afficher un indicateur)
  bool get isPercentageApplied => _percentageApplied;
  
  /// Getter pour obtenir la dernière valeur de pourcentage calculée
  /// Utile pour afficher le détail du calcul dans l'UI
  double get lastPercentageValue => _lastPercentageValue;

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
    _display = result.toString();
    _resetCalculator();
    _resetPercentageState();
    notifyListeners();
  }

  void clear() {
    _display = '0';
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
    _resetPercentageState();
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

  // ============================================================
  // FONCTIONNALITÉ POURCENTAGE
  // ============================================================
  // 
  // Choix architectural :
  // - La méthode percentage() est ajoutée dans le ViewModel car elle
  //   représente une logique métier (calcul) qui modifie l'état de l'UI.
  // - Elle respecte le pattern MVVM : la View appelle la méthode,
  //   le ViewModel effectue le calcul et notifie la View via notifyListeners().
  // 
  // Comportement :
  // - Si une opération est en attente (ex: 200 + 50%), calcule 50% de 200 = 100
  // - Sinon, divise simplement la valeur affichée par 100 (ex: 50 → 0.5)
  // ============================================================

  /// Calcule le pourcentage de la valeur actuelle.
  /// 
  /// Si une opération est en cours (ex: 200 + 50%), le pourcentage est calculé
  /// par rapport à la valeur stockée (_storedValue).
  /// Sinon, la valeur affichée est simplement divisée par 100.
  void percentage() {
    if (_display.isEmpty || _display == '0') return;

    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    double result;

    // Si une opération est en attente, calcule le pourcentage par rapport à _storedValue
    // Exemple : 200 + 50% → 200 + (200 * 50 / 100) = 200 + 100
    if (_pendingOperation.isNotEmpty && _storedValue != 0) {
      result = _storedValue * currentValue / 100;
    } else {
      // Sinon, divise simplement par 100
      // Exemple : 50% → 0.5
      result = currentValue / 100;
    }

    // Mise à jour des états pour le pourcentage
    _percentageApplied = true;
    _lastPercentageValue = result;
    
    _display = result.toString();
    _currentInput = _display;
    notifyListeners();
  }

  /// Réinitialise l'état du pourcentage
  /// Appelé lors d'un nouveau calcul ou clear
  void _resetPercentageState() {
    _percentageApplied = false;
    _lastPercentageValue = 0;
  }
}
