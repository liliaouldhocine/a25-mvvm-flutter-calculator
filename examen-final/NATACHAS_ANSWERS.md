# **Examen de Développement Flutter - Architecture MVVM**

Par Natacha MEYER

---

## **Partie 1 : Questions théoriques (30%)**

### **Question 1 : Architecture MVVM**

<details>
<summary>

1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.

</summary>

Les trois composants sont `Model`, `View` et `ViewModel`.
Le `Model` a le rôle de stocker les données et d'accéder aux sources.
La `View` a le rôle d'afficher l'interface et capter les interactions.
Le `ViewModel` a le rôle de contenir l'état et de gérer la logique. Il fait le lien entre la `View` et le `Model`.
</details>

<details>
<summary>

2. Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est l'alternative à `ChangeNotifier` dans Flutter ?

</summary>

`ChangeNotifier` est une classe fournie par Flutter pour créer un `Observer`. Elle permet à un objet (généralement le `ViewModel`) d'avoir la méthode de `notifyListeners()`.

`notifyListeners()` est une méthode fournie par `ChangeNotifier`. Quand l'état du `ViewModel` a été modifié ou a eu un changement d'état, il appelle à `notifyListeners()` pour informer tous ses `listeners` de mettre à jour/reconstruire l'UI.

Comme alternative,
On a l'option `Stream` / `StreamController`. Il permet de diffuser des événements ou des états de manière réactive, utile pour des flux continus (comme un Timer ou des données réseau).

</details>

<details>
<summary>

3. Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?

</summary>

Car ça permet d'éviter de mettre à jour/reconstruire des widgets inutilement. `Consumer<CalculatorViewModel>` écoute uniquement au changement à sa portion de l'UI concernée.

</details>

### **Question 2 : Séparation des préoccupations**

<details>
<summary>

1. La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?

</summary>

L’immutabilité garantit que les objets `Calculation` ne peuvent pas être modifiés après leur création.
Ça offre de la sécurité des données et de la prévisibilité.
</details>

<details>
<summary>

2. Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?

</summary>

En Dart, le préfixe `_` rend la __variable privée__ à la bibliothèque ; il est inaccessible depuis d'autres fichiers.
Cela renforce la séparation des préoccupations : la `View` ne manipule pas directement l’état, elle passe par le `ViewModel`.
</details>

<details>
<summary>

3. Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?

</summary>

On peut remplacer le switch par une abstraction « Operation » (stratégie) : chaque opération implémente une interface `apply(a, b)`.
Le `ViewModel` stocke une référence à `Operation` au lieu d'une chaîne.
Pour ajouter une opération, on crée une nouvelle classe implémentant `Operation`, sans devoir modifier le `ViewModel`!

</details>

### **Question 3 : Comparaison d'architectures**

<details>
<summary>

1. Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.

</summary>

Approche `setState()` de `StatefulWidget`:
**Avantage :** Simple et intuitif, idéal pour les petits widgets locaux et des cas d'usages rapides.
**Inconvénient :** On reconstruit TOUT le widget au complet, même si on change seulement une petite partie.

Approche `notifyListeners()` de `ChangeNotifier`:
**Avantage :** Plus performant, pusieurs widgets peuvent s'abonner finement, réduisant les rebuilds et améliorant la testabilité/maintenabilité.
**Inconvénient :** Peut-être mal géré, demande plus de configurations.

</details>

<details>
<summary>

2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?

</summary>

Chaque action utilisateur devient un event.
Le résultat affiché, l’historique, l’opération en cours deviennent des states émis par le BLoC.
Au lieu d’un `CalculatorViewModel` avec des méthodes et `notifyListeners()`, on aurait un `CalculatorBloc` qui reçoit des événements et émet des états via un Stream.
La View écoute les states via `BlocBuilder` ou `BlocListener` au lieu de `Consumer`.

</details>

<details>
<summary>

3. Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?

</summary>

`Provider` instancie le `CalculatorViewModel` et le place dans l'arbre des widgets pour que tous les descendants puissent y accéder.
Quand on omet le `ChangeNotifierProvider`, les widgets descendent ne trouveront plus d'instance, donc ils vont déclencher l'erreur que le `Provider` n'est pas trouvé à l'exécution.
</details>

---

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

<details>

<summary>

1. Identifiez 5 problèmes architecturaux ou techniques dans ce code.

</summary>

- `notifyListeners()` est manquée après des modifications d'état.
- Les variables `display` et `history` sont mutable et __publiques__, elles doivent être privées.
- L'historique est stocké étant une chaîne, pas un modèle `Calculation`.
- la représentation de l'expression dans display (par ex. "2+3") mélange l'UI et la logique métier.
- Le parsing/évaluation est naïf et fragile (seulement +, split unique), il n'a pas de gestion d'erreurs ni d'entrées invalides.

</details>

<details>

<summary>

2. Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.

</summary>

- Sans `notifyListeners()`: l’UI ne se met pas à jour.
- Les variables publiques: la `View` peut modifier directement l’état, ca peut casser l'encapsulation du ViewModel.
- L'historique: Il y a une perte de cohérence et de clarté dans l’historique (On veut garder l'expression et le resultat, pas juste le resultat.).
- Le melange UI/Logic: Il se rend difficile à maintenir et tester.
- Le parsing fragile: Le switch/split sur `display` empêche extension (autres opérateurs), est sujet aux erreurs (espaces, décimales, plusieurs opérateurs) et rend difficile à maintenir et tester.

</details>

<details>

<summary>

3. Réécrivez le code corrigé en respectant l'architecture MVVM et les bonnes pratiques Flutter.

</summary>

```dart
import 'package:flutter/material.dart';
import '../../lib/models/calculation.dart';

class FixedCalculatorViewModel extends ChangeNotifier {
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

  void clearAll() {
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
```

</details>

<details>

<summary>

4. Proposez un test unitaire pour la méthode `calculateResult()` qui couvre un cas d'erreur potentiel.

</summary>

Une test classique a faire: une division par zero.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:calculatrice_mvvm/viewmodels/buggy_calculator_viewmodel.dart';

void main() {
  test('calculateResult handles division by zero', () {
    final vm = CalculatorViewModel();

    // préparer l'état : 6 ÷ 0
    vm.inputNumber('6');
    vm.setOperation('÷');
    vm.inputNumber('0');

    vm.calculateResult();

    // affichage doit indiquer une erreur
    expect(vm.display, equals('Erreur'));

    // historique ne doit pas contenir une entrée valide
    expect(vm.history.isEmpty, isTrue);
  });
}
```

</details>

---

## **Partie 3 : Développement (40%)**

### **Consigne :**

Améliorez l'application calculatrice existante en ajoutant **une seule** des fonctionnalités suivantes. Choisissez la fonctionnalité qui correspond à votre numéro d'étudiant modulo 4 :

<!-- - **Option 0** : Ajouter un bouton "M+" (Mémoire Add) et "MR" (Memory Recall) avec une mémoire simple -->
<!-- - **Option 1** : Ajouter la possibilité de calculer les pourcentages (bouton "%") -->
<!-- - **Option 2** : Ajouter un historique des 5 derniers calculs affiché directement sur l'écran principal -->
- **Option 3** : Ajouter un mode "nuit" avec un thème sombre activable/désactivable

### **Exigences techniques :**

1. Respectez scrupuleusement l'architecture MVVM existante
2. Créez de nouveaux fichiers si nécessaire, mais ne modifiez pas le fonctionnement existant
3. Utilisez des getters appropriés pour exposer les nouveaux états
4. Ajoutez des commentaires expliquant vos choix architecturaux
5. Testez votre fonctionnalité sur l'émulateur avant la fin de l'examen

### **Structure attendue :**

<!-- Pour Option 0/1/2 :
- Extension de CalculatorViewModel avec nouvelles méthodes
- Modification de CalculatorScreen pour ajouter les boutons
- Tests unitaires pour la nouvelle logique -->

```txt
Pour Option 3 :
- Création d'un SettingsViewModel séparé
- Création d'un SettingsScreen
- Modification de main.dart pour gérer le thème
```

### **Points d'évaluation :**

- **Architecture** : Respect du pattern MVVM, séparation claire des responsabilités
- **Fonctionnalité** : La fonctionnalité ajoutée fonctionne correctement
- **Code qualité** : Code propre, commenté, nommage approprié
- **Gestion d'état** : Utilisation correcte de notifyListeners() et Consumer

---

## **Instructions pratiques :**

1. Créez un fork partir du code fourni
2. Travaillez sur une branche nommée "branche-examen-final"
3. À la fin des 2 heures, créez une Pull Request vers la branche main
4. Incluez dans la description de la PR :
   - Votre nom et prénom
   - L'option choisie pour la Partie 3
   - Un bref résumé de vos modifications
   - Ne mergez pas la PR !
   - Envoyez moi un lien vers cette PR comme remise

## **Ressources autorisées :**

- Documentation officielle Flutter (flutter.dev)
- Documentation Dart (dart.dev)
- Code source de l'application calculatrice fournie
- Votre propre code des TP précédents

## **Ressources interdites :**

- Code complet copié d'internet
- Communication avec d'autres étudiants
- Packages externes non autorisés

**Bon courage !**
