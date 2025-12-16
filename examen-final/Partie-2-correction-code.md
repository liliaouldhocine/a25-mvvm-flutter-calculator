1) Problèmes identifiés (5) + pourquoi c’est mauvais en MVVM

### Problème 1 — État public (display, history publics)
- *Pourquoi c’est mauvais :* la View (ou tout autre code) peut modifier l’état directement → pas d’encapsulation, incohérences possibles.
- *MVVM :* l’état doit être contrôlé par le ViewModel via des méthodes et exposé via des getters.

### Problème 2 — Parsing fragile dans calculateResult() (utilise display comme source de vérité)
- *Pourquoi c’est mauvais :* la logique métier dépend d’un texte d’affichage, difficile à faire évoluer et à tester.
- *MVVM :* la logique doit être stable, testable, et idéalement séparée de la représentation UI.

### Problème 3 — Absence de gestion d’erreurs (double.parse)
- *Pourquoi c’est mauvais :* une saisie invalide (ex: 12+, +3, 1+2+3) peut faire planter l’application.
- *Flutter/MVVM :* on doit sécuriser l’entrée utilisateur (tryParse) et retourner un état d’erreur.

### Problème 4 — Code non extensible (supporte seulement +)
- *Pourquoi c’est mauvais :* ajouter une nouvelle opération force à modifier calculateResult() (violation Open/Closed).
- *Bonne pratique :* isoler les opérations via stratégie / map d’opérations.

### Problème 5 — Historique peu utile (perte de l’expression)
- *Pourquoi c’est mauvais :* history.add(display) après calcul enregistre seulement le résultat, pas l’expression.
- *Bonne pratique :* stocker des entrées du type 12+3=15 pour traçabilité.

## 2) Code corrigé (MVVM + bonnes pratiques Flutter)

// Fichier : buggy_calculator_viewmodel.dart

import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  String _display = '0';  // Ligne modifiée
  final List<String> _history = [];  // Ligne modifiée

String get display => _display;
List<String> get History => List.unmodifiable(_history);

  void inputNumber(String number) {
    if (number.isEmpty) return;

    if (display == '0') {
      display = number;
    } else {
      _display += number;  // Ligne modifiée
    }
    notifyListeners();// Ligne manquante
  }

  void calculateResult() {
    final expression = _display.replaceAll(' ', '');

    if (!expression.contains('+')) {
      _display = 'Error';
      notifyListeners();
      return;
    }

    final parts = expression.split('+');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      _display = 'Error';
      notifyListeners();
      return;
    }

    final a = double.tryParse(parts[0]);
    final b = double.tryParse(parts[1]);

    if (a == null || b == null) {
      _display = 'Error';
      notifyListeners();
      return;
    }

    final result = a + b;
    final resultText = _formatNumber(result);

    _history.add('$expression=$resultText');
    _display = resultText;

    notifyListeners();
  }

  void clearAll() {
    display = '0';
    history.clear(); // pour vider l historique
    notifyListeners();// Ligne manquante
  }

String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @visibleForTesting
  void setDisplayForTest(String value) {
    _display = value;
  }
}


## Test unitaire proposé pour calculateResult()

### Cas d’erreur potentiel
Un cas d’erreur potentiel survient lorsque l’expression affichée est invalide, par exemple `"12+"`.  
Dans l’ancienne version du code, ce cas pouvait provoquer une exception lors de l’appel à `double.parse()`.

### Objectif du test
Le test unitaire vérifie que :
- la méthode `calculateResult()` ne fait pas planter l’application
- le ViewModel met l’état `display` à `"Error"` lorsque l’expression est invalide

### Exemple de test unitaire

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ton_projet/buggy_calculator_viewmodel.dart';

void main() {
  test('calculateResult() affiche Error pour une expression invalide', () {
    final viewModel = BuggyCalculatorViewModel();

    viewModel.setDisplayForTest('12+');
    viewModel.calculateResult();

    expect(viewModel.display, 'Error');
  });
}
