
# Partie 1 : Questions théoriques

## Question 1 : Architecture MVVM

### 1. Composants MVVM
- **Model** : Contient les données et la logique métier.
- **View** : Interface utilisateur (UI), affiche les données et capte les actions de l’utilisateur.
- **ViewModel** : Fait le lien entre View et Model, gère l’état et expose les données à la View.

### 2. ChangeNotifier et notifyListeners()
- **ChangeNotifier** : Permet au ViewModel de notifier la View lorsqu’un état change.
- **notifyListeners()** : Déclenche la mise à jour automatique de la View.
- **Alternative** : `Riverpod`, `Bloc/Cubit`, `ValueNotifier`.

### 3. Consumer vs Provider.of
- **Consumer<CalculatorViewModel>** : Reconstruit seulement le widget concerné lors d’un changement.
- **Provider.of<CalculatorViewModel>** : Peut reconstruire tout le widget parent.
- **Pourquoi Consumer** : Meilleure performance et code plus propre.

## Question 2 : Séparation des préoccupations

### 1. Immutabilité de `Calculation`
- Garantit que les données ne changent pas après création.
- Réduit les bugs liés aux effets de bord.

### 2. Underscore (_) dans `CalculatorViewModel`
- Indique des **variables privées**.
- Empêche l’accès direct depuis l’extérieur du fichier.

### 3. Refactorisation du `switch` (Open/Closed)
- Utiliser une **Map d’opérations -> fonctions**.
- Ou appliquer le **pattern Strategy**.
- Permet d’ajouter des opérations sans modifier le code existant.

## Question 3 : Comparaison d'architectures

### 1. setState() vs notifyListeners()
- **setState() (StatefulWidget)**
  - Avantage : simple et rapide pour un petit écran.
  - Inconvénient : logique + UI souvent mélangées, moins scalable.

- **notifyListeners() (ChangeNotifier / MVVM)**
  - Avantage : meilleure séparation (UI/logique), réutilisable/testable.
  - Inconvénient : plus de structure/boilerplate, risque de rebuilds si mal découpé.

### 2. Migration vers BLoC : changements principaux
- Remplacer le ViewModel par :
  - **Events** (actions utilisateur : tap bouton, clear, etc.)
  - **States** (display, history, error, etc.)
  - **Bloc/Cubit** (logique qui transforme Events -> States)
- La View écoute le **State** via `BlocBuilder` au lieu de `Consumer`.

### 3. Provider dans main.dart
- `ChangeNotifierProvider` crée et fournit une instance du ViewModel à toute l’app.
- Les widgets peuvent ensuite lire/écouter le ViewModel via `Consumer` / `context.watch()`.

- **Si on omet ChangeNotifierProvider :**
  - Le ViewModel n’est pas disponible dans l’arbre de widgets.
  - Erreur runtime typique : **ProviderNotFoundException**.

# Partie 2 : Correction de code

## 1- 5 problèmes (et pourquoi c’est mauvais en MVVM)

1) **État public mutable (`display`, `history`)**
- Mauvais : la View (ou n’importe qui) peut modifier l’état directement -> casse l’encapsulation du ViewModel.
- MVVM : on expose des **getters** en lecture seule, et on modifie via des méthodes.

2) **`notifyListeners()` manquant (dans inputNumber, calculateResult, clearAll)**
- Mauvais : la View ne se reconstruit pas -> UI “bloquée” / données désynchronisées.
- MVVM : le ViewModel doit notifier les changements d’état.

3) **`history` = `List<String>` + ajout incohérent**
- Mauvais : on perd le contexte (expression vs résultat), et on stocke juste `display` *après* calcul (souvent pas utile).
- MVVM : l’historique doit être un **Model** (ex. `Calculation(expression, result, timestamp)`).

4) **Logique de calcul fragile (parse naïf + pas de validation)**
- Mauvais : `split('+')` + `double.parse` peut planter (ex: "1+2+3", "1+", "+2", espaces, etc.).
- MVVM : la logique doit être robuste (validation/erreurs) et ne pas crasher l’app.

5) **Couplage “display = expression”**
- Mauvais : `display` sert à la fois d’affichage et de stockage de l’expression → mélange responsabilités et rend la logique difficile à maintenir.
- MVVM : séparer **l’état d’affichage** et **les données de calcul** (opérandes, opération, etc.).

---

## 2- Code corrigé (MVVM + bonnes pratiques)

```dart
// Fichier : calculator_viewmodel.dart
import 'package:flutter/foundation.dart';

class Calculation {
  final String expression;
  final double result;
  final DateTime timestamp;

  const Calculation({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  @override
  String toString() => '$expression = $result';
}

enum Operation { add, sub, mul, div }

class CalculatorViewModel extends ChangeNotifier {
  // --- État privé (encapsulation) ---
  String _display = '0';
  final List<Calculation> _history = [];

  double? _left;
  Operation? _op;
  bool _shouldClearOnNextDigit = false;

  // --- Getters publics (lecture seule) ---
  String get display => _display;
  List<Calculation> get history => List.unmodifiable(_history);

  // --- Actions (API du ViewModel) ---
  void inputNumber(String digit) {
    if (digit.isEmpty) return;

    if (_shouldClearOnNextDigit || _display == '0') {
      _display = digit;
      _shouldClearOnNextDigit = false;
    } else {
      _display += digit;
    }
    notifyListeners();
  }

  void setOperation(Operation op) {
    // Capture l’opérande gauche
    _left = double.tryParse(_display);
    _op = op;
    _shouldClearOnNextDigit = true;
    notifyListeners();
  }

  void calculateResult() {
    final left = _left;
    final op = _op;
    final right = double.tryParse(_display);

    if (left == null || op == null || right == null) {
      _display = 'Error';
      notifyListeners();
      return;
    }

    double result;
    switch (op) {
      case Operation.add:
        result = left + right;
        break;
      case Operation.sub:
        result = left - right;
        break;
      case Operation.mul:
        result = left * right;
        break;
      case Operation.div:
        if (right == 0) {
          _display = 'Error';
          notifyListeners();
          return;
        }
        result = left / right;
        break;
    }

    final expression = '${_format(left)} ${_symbol(op)} ${_format(right)}';
    _history.insert(
      0,
      Calculation(expression: expression, result: result, timestamp: DateTime.now()),
    );

    _display = _format(result);
    _left = null;
    _op = null;
    _shouldClearOnNextDigit = true;

    notifyListeners();
  }

  void clearAll() {
    _display = '0';
    _left = null;
    _op = null;
    _shouldClearOnNextDigit = false;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // --- Helpers ---
  String _symbol(Operation op) {
    switch (op) {
      case Operation.add: return '+';
      case Operation.sub: return '-';
      case Operation.mul: return '×';
      case Operation.div: return '÷';
    }
  }

  String _format(double v) {
    // pas de "2.0"
    final asInt = v.toInt();
    return (v == asInt.toDouble()) ? asInt.toString() : v.toString();
  }
}
```
# Partie 3 : Développement

**Option choisie : Option 3 — Mode nuit (thème sombre activable/désactivable)**  
Cette option ajoute un mode sombre contrôlé par un `SettingsViewModel` séparé, respectant l’architecture MVVM et permettant de basculer dynamiquement entre thème clair et thème sombre sans modifier la logique existante de la calculatrice.


