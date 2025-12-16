## **Partie 2 : Correction de code (30%)**

### **Code à analyser :**

```dart
// Fichier : buggy_calculator_viewmodel.dart

import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  String display = '0';  // Ligne modifiée
  List<String> history = [];  // Ligne modifiée

  void inputNumber(String number) {
    if (display == '0') {
      display = number;
    } else {
      display = display + number;  // Ligne modifiée
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
```

### **Questions de correction :**

**1. Identifiez 5 problèmes architecturaux ou techniques dans ce code.**

**Réponse :**

1. Variables publiques sans underscore. La View peut modifier `display` et `history` directement, sans encapsulation.
2. Il manque `notifyListeners()` dans toutes les méthodes. La View ne redessine pas quand l'état change.
3. Pas de getters pour accéder aux données. La View accède directement aux variables publiques au lieu de passer par des getters.
4. La logique de calcul est trop basique : elle fait seulement l'addition avec `split('+')`. Elle ne gère pas les autres opérations ni les erreurs.
5. `history` stocke des strings au lieu d'objets `Calculation` immuables. Les données du Model peuvent être modifiées par accident.

**2. Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.**

**Réponse :**

1. MVVM exige l'encapsulation. Les variables publiques cassent la séparation MVVM. La View ne doit pas accéder directement aux données.
2. Sans `notifyListeners()`, il n'y a pas de communication entre ViewModel et View. La View ne sait pas que l'état change.
3. Sans getters, la View accède directement aux variables. Les getters permettent de contrôler et valider l'accès aux données.
4. Une logique trop basique rend le code non-maintenable. Ajouter une opération nécessite modifier la méthode.
5. Les strings mutables créent des bugs. Le Model doit stocker des objets immuables pour éviter les modifications accidentelles.

**3. Réécrivez le code corrigé en respectant l'architecture MVVM et les bonnes pratiques Flutter.**

**Réponse :**

```dart
// Fichier : buggy_calculator_viewmodel.dart

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
```

4. Proposez un test unitaire pour la méthode `calculateResult()` qui couvre un cas d'erreur potentiel.
