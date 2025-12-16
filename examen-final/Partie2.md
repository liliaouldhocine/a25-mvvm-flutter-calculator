## 1. Problèmes identifiés (5 problèmes)

### Problème 1 — `notifyListeners()` manquant

- **Problème** : Les méthodes `inputNumber`, `calculateResult` et `clearAll` modifient l’état sans appeler `notifyListeners()`.
- **Pourquoi c’est une mauvaise pratique en MVVM** :  
  En MVVM, le ViewModel doit notifier la View lorsqu’un changement d’état survient. Sans `notifyListeners()`, l’interface utilisateur ne se met pas à jour.

---

### Problème 2 — Logique métier fragile dans `calculateResult`

- **Problème** : La méthode `calculateResult()` ne gère que l’opérateur `+` et suppose que l’expression est toujours valide.
- **Pourquoi c’est une mauvaise pratique en MVVM** :  
  Le ViewModel doit contenir une logique métier robuste et indépendante de la View. Une logique fragile peut provoquer des erreurs et des crashs.

---

### Problème 3 — Absence de gestion des erreurs

- **Problème** : L’utilisation de `double.parse()` sans gestion d’erreur peut provoquer une exception si l’entrée est invalide.
- **Pourquoi c’est une mauvaise pratique en MVVM** :  
  Le ViewModel doit gérer les erreurs pour garantir la stabilité de l’application et fournir un état cohérent à la View.

---

### Problème 4 — Gestion incorrecte de l’historique

- **Problème** : Seul le résultat est ajouté à l’historique, sans inclure l’expression complète.
- **Pourquoi c’est une mauvaise pratique en MVVM** :  
  Le ViewModel doit fournir des données complètes et cohérentes que la View peut afficher correctement.

---

### Problème 5 — Manque d’encapsulation

- **Problème** : Les variables `display` et `history` sont publiques et modifiables directement.
- **Pourquoi c’est une mauvaise pratique en MVVM** :  
  En MVVM, la View ne doit pas modifier directement l’état du ViewModel. L’encapsulation protège l’intégrité des données.

---

## 2. Code corrigé (respect de l’architecture MVVM)

```dart
import 'package:flutter/material.dart';

class CalculatorViewModel extends ChangeNotifier {
  String _display = '0';
  final List<String> _history = [];

  String get display => _display;
  List<String> get history => List.unmodifiable(_history);

  void inputNumber(String number) {
    if (_display == '0') {
      _display = number;
    } else {
      _display += number;
    }
    notifyListeners();
  }

  void calculateResult() {
    try {
      if (_display.contains('+')) {
        final parts = _display.split('+');
        if (parts.length != 2) {
          throw FormatException();
        }

        final double a = double.parse(parts[0]);
        final double b = double.parse(parts[1]);
        final double result = a + b;

        _history.add('$_display = $result');
        _display = result.toString();
      }
    } catch (e) {
      _display = 'Erreur';
    }
    notifyListeners();
  }

  void clearAll() {
    _display = '0';
    _history.clear();
    notifyListeners();
  }
}
```

---

## 3. Test unitaire — méthode `calculateResult()` (cas d’erreur)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/viewmodels/calculator_viewmodel.dart';

void main() {
  test('calculateResult affiche "Erreur" si expression invalide', () {
    final viewModel = CalculatorViewModel();

    viewModel.inputNumber('5');
    viewModel.inputNumber('+');
    viewModel.inputNumber('+');

    viewModel.calculateResult();

    expect(viewModel.display, 'Erreur');
  });
}
```

---

## Conclusion

- Le ViewModel ne contient aucune logique d’interface utilisateur.
- Chaque changement d’état appelle `notifyListeners()`.
- La logique métier est sécurisée et testable.
- Les données sont encapsulées et protégées.
- Le code respecte l’architecture MVVM et les bonnes pratiques Flutter.
