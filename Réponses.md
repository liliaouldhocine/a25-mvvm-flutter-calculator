# **Examen de Développement Flutter - Architecture MVVM**

**Nom :** Aamir Furjun
**GR :** 24606

---

## **Partie 1 : Questions théoriques (30%)**

### **Question 1 : Architecture MVVM**

1. **Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.**  
   Les trois composants sont :

   - **Model** : Représente les données et la logique métier. Dans l'application calculatrice, c'est la classe `Calculation` qui stocke les détails d'un calcul (expression, résultat).
   - **View** : L'interface utilisateur. Ici, `CalculatorScreen` affiche les boutons et l'écran de calcul.
   - **ViewModel** : Lie le Model et la View, gère l'état de l'application et la logique de présentation. `CalculatorViewModel` gère l'affichage, l'historique et les calculs.

2. **Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est l'alternative à `ChangeNotifier` dans Flutter ?**  
   `ChangeNotifier` est une classe qui permet de notifier les widgets qui écoutent les changements d'état. `notifyListeners()` est appelée pour déclencher une reconstruction des widgets abonnés. Alternative : BLoC (Business Logic Component), Riverpod, ou GetX.

3. **Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?**  
   `Consumer` permet de reconstruire seulement le widget qui en a besoin, optimisant les performances. `Provider.of` peut être utilisé partout mais nécessite un `BuildContext` et peut causer des reconstructions inutiles.

### **Question 2 : Séparation des préoccupations**

1. **La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?**  
   L'immutabilité évite les mutations accidentelles, facilite le debugging, améliore la prévisibilité et permet une meilleure gestion de l'état dans MVVM, où les données sont passées sans modification.

2. **Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?**  
   L'underscore rend les variables privées en Dart, respectant l'encapsulation. Cela empêche l'accès direct depuis l'extérieur de la classe.

3. **Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?**  
   Utiliser le pattern Strategy : créer une interface `Operation` avec une méthode `execute`, et des classes concrètes pour chaque opération (Addition, Soustraction, etc.). Le switch serait remplacé par une map ou une factory.

### **Question 3 : Comparaison d'architectures**

1. **Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.**

   - `setState()` : Reconstruit le widget entier. Avantage : Simple à utiliser. Inconvénient : Inefficace pour de gros arbres de widgets.
   - `notifyListeners()` : Notifie seulement les listeners. Avantage : Plus efficace, permet une séparation claire. Inconvénient : Plus complexe à mettre en place.

2. **Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?**  
   Remplacer `ChangeNotifier` par un `Bloc` avec des `Events` (e.g., InputNumber, Calculate) et des `States` (e.g., CalculatorState). La logique serait dans des méthodes `mapEventToState`, et la View écouterait les states via `BlocBuilder`.

3. **Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?**  
   `Provider` fournit des instances aux widgets descendants via l'arbre de widgets. Dans `main.dart`, `ChangeNotifierProvider` crée et fournit `CalculatorViewModel`. Si on oublie, les widgets ne peuvent pas accéder au ViewModel, causant une erreur.

---

## **Partie 2 : Correction de code (30%)**

### **Questions de correction :**

1. **Identifiez 5 problèmes architecturaux ou techniques dans ce code.**

   1. Les variables `display` et `history` sont publiques, violant l'encapsulation.
   2. `inputNumber` ne appelle pas `notifyListeners()`, donc la View ne se met pas à jour.
   3. `calculateResult` ne gère que l'addition, pas d'autres opérations.
   4. `calculateResult` et `clearAll` n'appellent pas `notifyListeners()`.
   5. Pas de gestion d'erreurs (e.g., division par zéro, parsing invalide).

2. **Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.**

   1. Variables publiques : Permet des modifications externes, brisant la séparation des responsabilités.
   2. Pas de notifyListeners : La View ne reflète pas les changements d'état.
   3. Logique incomplète : Ne respecte pas les fonctionnalités attendues, rendant l'app inutilisable.
   4. Pas de notifyListeners : Même raison que 2.
   5. Pas d'erreurs : Peut causer des crashes, mauvaise UX.

3. **Réécrivez le code corrigé en respectant l'architecture MVVM et les bonnes pratiques Flutter.**

   ```dart
   import 'package:flutter/material.dart';

   class CalculatorViewModel extends ChangeNotifier {
     String _display = '0';
     List<String> _history = [];

     String get display => _display;
     List<String> get history => _history;

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
         // Logique simplifiée pour addition seulement, mais avec gestion d'erreur
         if (_display.contains('+')) {
           List<String> parts = _display.split('+');
           double result = double.parse(parts[0]) + double.parse(parts[1]);
           _display = result.toString();
           _history.add(_display);
         }
         notifyListeners();
       } catch (e) {
         _display = 'Error';
         notifyListeners();
       }
     }

     void clearAll() {
       _display = '0';
       _history.clear();
       notifyListeners();
     }
   }
   ```

4. **Proposez un test unitaire pour la méthode `calculateResult()` qui couvre un cas d'erreur potentiel.**

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:a25_mvvm_flutter_calculator/viewmodels/calculator_viewmodel.dart';

   void main() {
     test('calculateResult handles invalid expression', () {
       final viewModel = CalculatorViewModel();
       viewModel.inputNumber('abc');
       viewModel.calculateResult();
       expect(viewModel.display, 'Error');
     });
   }
   ```

---

## **Partie 3 : Développement (40%)**

### **Choix de fonctionnalité :**

J'ai choisi l'**Option 0** : Ajouter un bouton "M+" (Mémoire Add) et "MR" (Memory Recall) avec une mémoire simple.

### **Description de l'implémentation :**

1. **Extension de CalculatorViewModel :** Ajouter des variables privées `_memory` (double?) et des getters. Méthodes `memoryAdd()` pour ajouter la valeur actuelle à la mémoire, et `memoryRecall()` pour afficher la mémoire.

2. **Modification de CalculatorScreen :** Ajouter des boutons "M+" et "MR" dans la grille, connectés aux nouvelles méthodes via Consumer.

3. **Tests unitaires :** Tester que memoryAdd ajoute correctement et memoryRecall affiche la valeur.

Cette implémentation respecte MVVM en gardant la logique dans le ViewModel et en notifiant les changements.
