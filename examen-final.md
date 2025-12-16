# Examen Final - Architecture MVVM Flutter

Partie 1
---

## Question 1 : Architecture MVVM

### 1.1 Composants de l'architecture MVVM

Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.

models : Les models représente toute les données derrière l'application

viewmodels : c'est ceux qui font le pont entre les models et les views

views : les views sont les interfaces graphiques que verra l'utilisateur. (UI)

---

### 1.2 ChangeNotifier et notifyListeners()

Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est l'alternative à `ChangeNotifier` dans Flutter ?

Rôle : 
'ChangeNotifier' : Le changeNotifer permet au Views d'être avertis lorsqu'une données change

'notifyListeners()' : Lui informe les views qu'un changement a été apporté pour qu'une mise à jours se déclenche.

L'alternative dans Flutter serait ValueNotifier.

---

### 1.3 Consumer vs Provider.of

Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?

Pour l'instant l'application tel quel n'utilise pas encore Consumer, uniquement Provider.of.
Mais en changant pour consumer on pourrait éviter de recharger tous les boutons présents.
En ce moment à chaque fois qu'une action modifie l'affichage (0-9, +,-, etc) tout l'écran se rebuild.  Avec consumer on pourrait limiter ça à seulement la partie qui change. (Texte affiché)

---

## Question 2 : Séparation des préoccupations

### 2.1 Immutabilité du modèle

La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?

C'est une bonne pratique dans le cas d'une architecture MVVM, cela évite de pouvoir modifier les données accidentellement. Dans le cas présent cela assure entre autres que l'historique des calculs ne soit modifié.

---

### 2.2 Encapsulation avec underscore

Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?

L'underscore permet de rendre les données privées à la bibliothèque.
Dans cette app, ça protège l'affichage et l'historique d'être accédés et modifiés directement. On peut seulement y accéder via des getters.


---

### 2.3 Principe Open/Closed (SOLID)

Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?

Idéalement, on devrait créer des classes pour chaque opération et ensuite refactoriser le ViewModel pour appeler chacune de ces nouvelles classes.
On sépare ainsi les responsabilités.
Après, ce sera beaucoup plus simple d'ajouter de nouvelles fonctions.



---

## Question 3 : Comparaison d'architectures

### 3.1 setState() vs notifyListeners()

Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.

'setState()',(StatefulWidget) :

Pros : Déjà intégré dans flutter (pas besoins d'ajouter un package), pas de dépendance externe


Cons : C'est mélangé avec l'UI, on reconstruit le widget au complet à chaque fois



notifyListeners(), (ChangeNotifier) :

Pros : c'est la bonne pratique pour une app MVVM, facile de faire la séparation des responsabilités


Cons : ça demande un Provider, ce qui peut être un peu plus difficile à intégrer

---

### 3.2 Migration vers BLoC

Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?

On commencerait par remplacer le ChangeNotifier par Bloc.
Ensuite on devrait remplacer les variables _display, _history par une classe du genre CalculatorState avec tous les champs en 'final'
Il faudrait aussi remplacer notifyListeners() par emit()
Et finalement dans main.dart il faudrait remplacer le ChangeNotifierProvider par BlocProvider

---

### 3.3 Fonctionnement de Provider

Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?

Le ChangeNotifierProvider crée et donne le ViewModel aux widgets.
Si on ne le met pas, le Provider.of ne va rien trouver et l'app ne fonctionnera tout simplement pas.

ChangeNotifierProvider(
  create: (context) => CalculatorViewModel(),  // On crée le ViewModel
  child: MaterialApp(
    home: CalculatorScreen(),  // Le widget peut y accéder
  ),
)

---

## Partie 2 : Analyse et correction de code

---

## Question 4 : Analyse de code buggy

### Code à analyser

**Fichier :** `buggy_calculator_viewmodel.dart`

```dart
import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  //PROBLÈME 1 : Variables publiques au lieu de privées
  // Les variables devraient avoir un _
  String display = '0';  
  List<String> history = [];  

  void inputNumber(String number) {
    if (display == '0') {
      display = number;
    } else {
      display = display + number;
    }
    //PROBLÈME 2 : notifyListeners() manquant
    // L'UI ne se mettra pas à jours
  }

  void calculateResult() {
    //PROBLÈME 4 : On ne gère que les additions, en plus de ne pas gérer les erreurs. 
    double result = 0;
    if (display.contains('+')) {
      List<String> parts = display.split('+');
      result = double.parse(parts[0]) + double.parse(parts[1]);
    }
    display = result.toString();
    //PROBLÈME 5 : Historique stocké comme List<String> au lieu d'objets structurés, on perd des informations
    history.add(display);
    //PROBLÈME 2 : notifyListeners() manquant
  }

  void clearAll() {
    display = '0';
    //PROBLÈME 2 : notifyListeners() manquant
  }
  
// PROBLÈME 3 : Pas de getters donc les variables sont directement accessibles, donc vulnérable au changement venant de n'importe quel fichier ou classe qui utilise le ViewModel
```

---

### Identification des 5 problèmes

#### Problème 1 : Les variables sont publiques au lieu de privées 

**Problème :** `display` et `history` sont publiques, pas `_display` et `_history`

**Pourquoi c'est mauvais en MVVM :**

- La View peut modifier directement l'état
-  On n'a pas le contrôle sur les modifications depuis l'extérieur de la classe


---

#### Problème 2 : Absence de notifyListeners()


**Problème :** `inputNumber()`, `calculateResult()` et `clearAll()` n'appellent pas `notifyListeners()`

**Pourquoi c'est mauvais en MVVM :**

- L'UI ne se met pas à jour après les changements d'état
- L'utilisateur ne voit pas les modifications en temps réel

---

#### Problème 3 : Pas de getters pour l'accès contrôlé


**Problème :** Accès direct aux variables publiques sans contrôle

**Pourquoi c'est mauvais en MVVM :**

-On n'a pas de contrôle sur la lecture des données



---

#### Problème 4 : La logique est simple et fragile


**Problème :** `calculateResult()` utilise `split('+')` qui gère seulement un opérateur (+) et on a pas de gestions d'erreur. (exemple si on entre un mauvais caractère)

**Pourquoi c'est mauvais en MVVM :**

- On gère seulement l'addition, pas les soustraction, multiplication, division etc...
- Pas de gestion d'erreur, donc l'app peu planter.


---

#### Problème 5 : Historique stocké comme List<String> au lieu d'objets structurés

**Problème :** `history` est une `List<String>` au lieu de `List<Calculation>`

**Pourquoi c'est mauvais en MVVM :**

-On ne respecte pas la séparation Model/ViewModel

---

### Code corrigé

```dart
import 'package:flutter/material.dart';
import '../models/calculation.dart';

class CalculatorViewModel extends ChangeNotifier {
  //Variables privées avec underscore
  String _display = '0';
  String _currentInput = '';
  String _pendingOperation = '';
  double _storedValue = 0;
  final List<Calculation> _history = [];

  //Getters pour accès contrôlé
  String get display => _display;
  List<Calculation> get history => List.unmodifiable(_history);

  void inputNumber(String number) {
    if (_display == '0' || _pendingOperation.isNotEmpty) {
      _display = number;
    } else {
      _display += number;
    }
    _currentInput = _display;
    notifyListeners(); //Notifie les listeners
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

    try {
      final currentValue = double.parse(_currentInput);
      double result = 0;

      //Logique complète avec toutes les opérations
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
          if (currentValue == 0) {
            _display = 'Erreur';
            _resetCalculator();
            notifyListeners();
            return;
          }
          result = _storedValue / currentValue;
          break;
        default:
          return;
      }

      //Utilise le modèle Calculation
      final calculation = Calculation(
        expression: '$_storedValue $_pendingOperation $currentValue',
        result: result,
        timestamp: DateTime.now(),
      );

      _history.add(calculation);
      _display = result.toString();
      _resetCalculator();
      notifyListeners(); //Notifie les listeners
    } catch (e) {
      //Gestion d'erreur
      _display = 'Erreur';
      _resetCalculator();
      notifyListeners();
    }
  }

  void clearAll() {
    _display = '0';
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
    notifyListeners(); //Notifie les listeners
  }

  void _resetCalculator() {
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
  }
}
```

---

### Test unitaire

**Test pour `calculateResult()` - Cas d'erreur : division par zéro**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';

void main() {
  group('CalculatorViewModel - calculateResult()', () {
    test('devrait gérer la division par zéro et afficher "Erreur"', () {
      // Arrange
      final viewModel = CalculatorViewModel();
      viewModel.inputNumber('25');
      viewModel.setOperation('÷');
      viewModel.inputNumber('0');

      // Act
      viewModel.calculateResult();

      // Assert
      expect(viewModel.display, 'Erreur');
      expect(viewModel.history.length, 0); // Aucun calcul ajouté à l'historique
    });

    test('devrait gérer une opération invalide sans planter', () {
      // Arrange
      final viewModel = CalculatorViewModel();
      viewModel.inputNumber('12');
      
      // Act & Assert - Ne devrait pas planter
      expect(() => viewModel.calculateResult(), returnsNormally);
    });

    test('devrait ajouter un calcul à l\'historique après un calcul réussi', () {
      // Arrange
      final viewModel = CalculatorViewModel();
      viewModel.inputNumber('7');
      viewModel.setOperation('+');
      viewModel.inputNumber('4');

      // Act
      viewModel.calculateResult();

      // Assert
      expect(viewModel.display, '11.0');
      expect(viewModel.history.length, 1);
      expect(viewModel.history[0].result, 11.0);
      expect(viewModel.history[0].expression, contains('7'));
      expect(viewModel.history[0].expression, contains('+'));
      expect(viewModel.history[0].expression, contains('4'));
    });
  });
}
```

---