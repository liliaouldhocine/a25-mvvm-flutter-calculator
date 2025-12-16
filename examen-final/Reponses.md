## **Partie 1 : Questions théoriques**

### **Question 1 : Architecture MVVM**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#question-1--architecture-mvvm)

1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.

   - Composant 1: Le model represente les donnes de l'appli ation. La classe calculation est un model. Ce model stock des donnes pures.
   - Composant 2: La view est l'interface utilisateur. Affiche les buttons de la calculatrice, capture les entrees utilisateur ``t l``s passe au viewModel.
   - Composant 3: Le viewModel contient la logique metier. Fait les calcul, garde l'historique ...
2. Expliquez le rôle de `ChangeNotifier` et `notifyLis`t `eners()`dans le ViewModel. Quelle est l'alternative à  `ChangeNotifier` dans Flutter ?

   - ChangeNotifier sert a notifier les widgets abonnees a l'event.
   - NotifyListener sert a declancher la notification a tout les widget abonnees.
   - A la place de changeNotifier, on peut utiliser un ValueNotifier qui est plus leger.
3. Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?

   - C'est principalement pour optimiser le rebuild en reconstruisant seulement les parties qui changent.

### **Question 2 : Séparation des préoccupations**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#question-2--s%C3%A9paration-des-pr%C3%A9occupations)

1. La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?
   - Pour garantir une integrite des donnes de l'hystorique. Plus previsible et facile a deboguer.
2. Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?
   - Comme pour beaucoup de langage comme le c++, le _ devant un nom de variable veut dire qu'elle est prive a la classe.
3. Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?
   - Faire des petites classe (1 par operation)  et refactoriser calculateResult() pour implementer un state machine patern pour respecter ce principe.

### **Question 3 : Comparaison d'architectures**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#question-3--comparaison-darchitectures)

1. Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.
   - Avantage: Pour avoir une separation claire entre le UI et la logique metier.
   - Inconveniant: Necessite un autre gestion d'etat comme un provider qui est plus complex a configurer.
2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?
   - Il faudrait changer changeNotifier par bloc.
   - Creer des events au lieu d'utiliser directement les methodes.
   - Transformet les methodes en gestionnaire d'evenement
   - Il faudrait changer aussi notifierListener par emit
3. Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?
   - Le changeNotifier cree une instance de calculatorViewModel
   - Il l'ajoute aux events widget
   - Il ecoute notifyListener
   - Si on omet le ChangeNotifierProvider il va y avoir une erreur. Le viewModel ne sera plus trouver dans l'arbre des widget.

---

## **Partie 2 : Correction de code (30%)**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#partie-2--correction-de-code-30)

### **Code à analyser :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#code-%C3%A0-analyser-)

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

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#questions-de-correction-)

1. Identifiez 5 problèmes architecturaux ou techniques dans ce code.

   - Il y a des variables public qui devraient etre prive
   - Il n'y a aucune trace du notifyerListener
   - Aucune verification d'erreur pour le double.parse()
   - Pour une persistance des donnees, history stock des strings au lieu d'objets.
   - Le code ne gere que le + et non tout les symboles.

   ---
2. Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.

   - Le ViewModel doit controler l'acces, la on peut atteindre les variable de nimporte ou.
   - Sans le notifyListener, le flux de donnees unidirectionnel est rompus.
   - Le programme pourrait crash si on ne verifie pas la convertion en double.
   - Les donnees doivent etre immuables
   - La logique metier et le ui ne sont pas disocier.
3. Réécrivez le code corrigé en respectant l'architecture MVVM et les bonnes pratiques Flutter.

   ```dart
   import 'package:flutter/material.dart';
   import '../models/calculation.dart';

   class CalculatorViewModel extends ChangeNotifier {
     // Variables privées pour l'encapsulation
     String _display = '0';
     String _currentInput = '';
     String _pendingOperation = '';
     double _storedValue = 0;
     final List<Calculation> _history = [];

     // Getters publics en lecture seule
     String get display => _display;
     List<Calculation> get history => List.unmodifiable(_history);

     void inputNumber(String number) {
       if (_display == '0' || _pendingOperation.isNotEmpty) {
         _display = number;
       } else {
         _display += number;
       }
       _currentInput = _display;
       notifyListeners(); // Notification obligatoire
     }

     void calculateResult() {
       if (_pendingOperation.isEmpty || _currentInput.isEmpty) return;

       double currentValue;
       try {
         currentValue = double.parse(_currentInput);
       } on FormatException {
         _display = 'Erreur';
         _resetCalculator();
         notifyListeners();
         return;
       }

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

       // Utilisation du modèle Calculation au lieu de String
       final calculation = Calculation(
         expression: '$_storedValue $_pendingOperation $currentValue',
         result: result,
         timestamp: DateTime.now(),
       );

       _history.add(calculation);
       _display = result.toString();
       _resetCalculator();
       notifyListeners(); // Notification obligatoire
     }

     void clearAll() {
       _display = '0';
       _currentInput = '';
       _pendingOperation = '';
       _storedValue = 0;
       notifyListeners(); // Notification obligatoire
     }

     void _resetCalculator() {
       _currentInput = '';
       _pendingOperation = '';
       _storedValue = 0;
     }
   }
   ```
4. Proposez un test unitaire pour la méthode `calculateResult()` qui couvre un cas d'erreur potentiel.

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';

   void main() {
     group('CalculatorViewModel - calculateResult()', () {
       test('devrait gérer l'erreur de division par zero', () {
         // Arrange : Préparer le ViewModel avec une division par zéro
         final viewModel = CalculatorViewModel();

         // Configurer l'etat : 10 ÷ 0
         viewModel.inputNumber('10');
         viewModel.setOperation('÷');
         viewModel.inputNumber('0');

         // Executer le calcul
         viewModel.calculateResult();

         // Verifier que l'erreur est geree correctement
         expect(viewModel.display, equals('Erreur'));
         expect(viewModel.history.length, equals(0));

         // Verifier que le calculateur est reinitialise
         viewModel.inputNumber('5');
         expect(viewModel.display, equals('5'));
       });
     });
   }py
   ```

---

## **Partie 3 : Développement (40%)**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#partie-3--d%C3%A9veloppement-40)

### **Consigne :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#consigne-)

Améliorez l'application calculatrice existante en ajoutant **une seule** des fonctionnalités suivantes. Choisissez la fonctionnalité qui correspond à votre numéro d'étudiant modulo 4 :

* **Option 0** : Ajouter un bouton "M+" (Mémoire Add) et "MR" (Memory Recall) avec une mémoire simple
* **Option 1** : Ajouter la possibilité de calculer les pourcentages (bouton "%")
* **Option 2** : Ajouter un historique des 5 derniers calculs affiché directement sur l'écran principal
* **Option 3** : Ajouter un mode "nuit" avec un thème sombre activable/désactivable

### **Exigences techniques :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#exigences-techniques-)

1. Respectez scrupuleusement l'architecture MVVM existante
2. Créez de nouveaux fichiers si nécessaire, mais ne modifiez pas le fonctionnement existant
3. Utilisez des getters appropriés pour exposer les nouveaux états
4. Ajoutez des commentaires expliquant vos choix architecturaux
5. Testez votre fonctionnalité sur l'émulateur avant la fin de l'examen

### **Structure attendue :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#structure-attendue-)

```
Pour Option 0/1/2 :
- Extension de CalculatorViewModel avec nouvelles méthodes
- Modification de CalculatorScreen pour ajouter les boutons
- Tests unitaires pour la nouvelle logique

Pour Option 3 :
- Création d'un SettingsViewModel séparé
- Création d'un SettingsScreen
- Modification de main.dart pour gérer le thème
```

### **Points d'évaluation :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#points-d%C3%A9valuation-)

* **Architecture** : Respect du pattern MVVM, séparation claire des responsabilités
* **Fonctionnalité** : La fonctionnalité ajoutée fonctionne correctement
* **Code qualité** : Code propre, commenté, nommage approprié
* **Gestion d'état** : Utilisation correcte de notifyListeners() et Consumer

---

## **Instructions pratiques :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#instructions-pratiques-)

1. Créez un fork partir du code fourni
2. Travaillez sur une branche nommée "branche-examen-final"
3. À la fin des 2 heures, créez une Pull Request vers la branche main
4. Incluez dans la description de la PR :
   * Votre nom et prénom
   * L'option choisie pour la Partie 3
   * Un bref résumé de vos modifications
   * Ne mergez pas la PR !
   * Envoyez moi un lien vers cette PR comme remise

## **Ressources autorisées :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#ressources-autoris%C3%A9es-)

* Documentation officielle Flutter (flutter.dev)
* Documentation Dart (dart.dev)
* Code source de l'application calculatrice fournie
* Votre propre code des TP précédents

## **Ressources interdites :**

[](https://github.com/liliaouldhocine/a25-dam-2-examen-final#ressources-interdites-)

* Code complet copié d'internet
* Communication avec d'autres étudiants
* Packages externes non autorisés

**Bon courage !**
