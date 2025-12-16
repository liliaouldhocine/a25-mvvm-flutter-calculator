## **Partie 1 : Questions théoriques (30%)**

### **Question 1 : Architecture MVVM**

1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.

M = Model -> Represente les donnees et la logique metier. La classe calculation qui encapsule les operations mathematique

V= View -> represente l'interface utilisateur, donc representer les boutons et l'ecran d'affichage

vm=  ViewModel -> fait le lien entre model et view, gere les etats d'affichages, la logique et l'historique de calcul.

2. Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est 
l'alternative à `ChangeNotifier` dans Flutter ?

`ChangeNotifier` = implemente un patern observer/observable  qui permet au viewmodel de notifier ses observateur  lors d'un changement d'etat

`notifyListeners()` = Methode appele a chaque modification qui declenche la reconstruction des widget lorsquil change d'etats

Alternative=  Streambuilder pour une approche reactive.

3. Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?

Reconstruit uniquement le widget enfant contenu dans son builder, plus performant et syntaxe declarative plus lisible.

### **Question 2 : Séparation des préoccupations**

1. La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?

Previsibilite:  L'etat  ne peux etre modifie accidentellement apres creation
Thread-safety : Pas de problemes de concurrence
Comparaison facile : Deux objets avec les memes valeurs sont egaux
Historique fiable : Chaque calcul dans l'historique reste intact
Debugging facilite : L'etat à un moment donnée est garanti de ne pas changer

2. Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?

_ rend une variable privee a sa bibliotheque et respect le principe d'encapsulation. Cela force l'utilisation des getter/setter, permet de valider ou transformer les donnee avant exposition et evide les modifications non controlees de l'etats


3. Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?

Le principe Open/Closed stipule qu'une classe doit être ouverte à l'extension mais fermée a la modification.

  Solution avec le Pattern Strategy :

  // Interface pour les opérations
  abstract class Operation {
    double execute(double a, double b);
  }

  // Implémentations concrètes
  class AddOperation implements Operation {
    double execute(double a, double b) => a + b;
  }

  class SubtractOperation implements Operation {
    double execute(double a, double b) => a - b;
  }

  // Map d'opérations dans le ViewModel
  final Map<String, Operation> _operations = {
    '+': AddOperation(),
    '-': SubtractOperation(),
    // Ajouter de nouvelles opérations sans modifier le code existant
  };

  // Utilisation
  double result = _operations[_pendingOperation]!.execute(a, b);

### **Question 3 : Comparaison d'architectures**

1. Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.

`setState()` (StatefulWidget) ->   Avantage =  Simple, integré a flutter, pas de dépendance externe   Inconvenient = État local au widget , difficile a partager entre widget

`StatefulWidget` (ChangeNotifier)  -> Avantage =  État partageable, séparation claire UI/logique, testable  Inconvenient = Configuration plus complexe, courbe d'apprentisage.

2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?

1 Remplacer ChangerNotifier par une class Bloc ou Cubit
2 Definir  des Events 
3 definir des States 
4 Remplacer  les methodes par des handlers d'event
5 Utilser emit() au lieu de notifyListeners()
6 Remplacer consumer par BlocBuilder et BlocConsumer


3. Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?

`ChangeNotifierProvider` cree une instacne du viewmodel  et le rend accessible a tous les widgets descendants dans l'arbre des widgtes. Il écoute les notifyListeners() et déclenche les rebuilds des Consumer abonnés.

si on Omet `ChangeNotifierProvider` l'application crache, car aucune instance du ViewModel n'est trouvés dasn l'arbre de widget.