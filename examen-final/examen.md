**Canada Badiane Gr: 24606**

# Examen de Développement Flutter - Architecture MVVM

## Partie 1 : Questions théoriques

### Question 1 : Architecture MVVM

1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.

Le premier composant de l'architechture MVVM est le View. Dans le contexte de la calculatrice, le View sert à afficher l'intertface de la calculatrice. Autrement dit, le View ne doit contenir aucune logique uniquement l'UI exemple les boutons de la calculatrice. Le deuxième composant est le ViewModels. Dans ce contexte, il sert à créer la logique des opérations mathématiques de la calculatrice. Cette partie ne gère aucunement l'interface et ne connait pas la View. Le troisième composant est le models. Dans ce contexte, il sert à stocker et structurer les données de la calculatrice. Les trois variables sont expression, result et timestamp. Chaque opération est stockée en objet et est utilisée dans la page historique.

2. Expliquez le rôle de ChangeNotifier et notifyListeners() dans le ViewModel. Quelle est l'alternative à ChangeNotifier dans Flutter ?

ChangeNotifier est un mécanisme d'observation qui a une méthode appelé notifyListeners(). Cette méthode permet d'envoyer une notification à tous les abonnés (ceux qui écoutent) lorsque les données changent. Dans ce contexte, à chaque fois qu'il y a un changement dans le ViewModels, par exemple \_display qui change, on fait appel à notifyListeners() pour qu'elle envoie le changement à View (abonné). L'alternative à ChangeNotifier dans Flutter serait d'utiliser les Provider qui écoutent également les changements d'états.

3. Pourquoi utilise-t-on Consumer<CalculatorViewModel> au lieu de Provider.of<CalculatorViewModel> dans certaines parties de la View ?

Le Consumer permet d'optimiser les performances on faisant un rebuild uniquement sur une partie du code de la View sans nécessiter un rebuild globale. Le rebuild est alors effectué que là où il y a des changements sur l'interface. Provider.of quant à lui, fait un rebuild globale meme si le changement se fait sur une partie de l'interface de la View. Pour des gros projets, vaut mieux utiliser Consumer.

### Question 2 : Séparation des préoccupations

1. La classe Calculation dans le dossier models/ est immuable (tous les champs sont final). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?

Le fait que la classe Calculation est immuable permet de renforcer la sécurité des données en ne permettant qu'une lecture des données sans possibilité de modifications. Cette stratégie est avantageuse dans le contexte de l'architecture MVVM puisque ca permet à la View de lire uniquement les données de models sans possibilité de modification. Ainsi, chaque composant respecte son role sans plus, afin de correspondre à l'architecture MVVM.

2. Pourquoi les variables dans CalculatorViewModel sont-elles préfixées par un underscore (\_display, \_history, etc.) ? Quelle règle de Dart cela respecte-t-il ?

Les underscores devant les variables signifies que les variables en question sont privées. Donc elles ne peuvent etre utilisées que dans leur classe. Seul l'utilisation des getters permettent leur lecture hors de la classe. Cela permet à la View de n'avoir aucun accès à la modification des variables uniquement leur lecture grace aux getters.

3. Dans calculator_viewmodel.dart, la méthode calculateResult() contient un switch sur \_pendingOperation. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?

### Question 3 : Comparaison d'architectures

1. Comparez l'approche setState() de StatefulWidget avec l'approche notifyListeners() de ChangeNotifier. Donnez un avantage et un inconvénient pour chaque approche.

setState() de StatefulWidget permet de mettre à jour des données et crée ensuite un rebuild. L'inconvénient c'est que le setState() crée un rebuild complet de l'interface à chaque fois qu'il est exécuté.

notifyListeners() de ChangeNotifier permet d'envoyer une notification aux abonnés (ceux qui écoutent) de manière automatique lorsqu'une donnée change. L'inconvénient est que ca crée une reconstruction de tous les widgets qui écoutent meme si un seul widget a été modifié.

2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?

Pour migrer cette application vers une architecture BLoC, il faudrait créer une classe d'état immuable au lieu de créer plusieurs variables privées et au lieu d'utiliser notifyListeners() on devrait utiliser un flux d'évènements pour les états.

3. Expliquez comment Provider fonctionne dans main.dart. Que se passe-t-il si on omet le ChangeNotifierProvider ?

Dans main.dart, si on omet le ChangeNotifierProvider on ne pourrait pas créé l'instance de CalculatorViewModel ni la mettre dans l'arbre des widgets pour ensuite l'utiliser partout dans l'application. Ce qui empecherait la communication entre le View et le ViewModels.

## Partie 2 : Correction de code

1. Identifiez 5 problèmes architecturaux ou techniques dans ce code. Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.

- List<String> history = []; Ici, sans final la liste peut etre modifiée après exécution du programme, ce qui pourrait engendrer une mauvaise information des opérations si expression, result ou timestamp était modifiée. C'est une mauvaise pratique dans le contexte MVVM puisque le View aurait accès à la modification de cette liste or elle ne devrait que pouvoir la lire pour respecter son role d'affichage.
- String display = '0'; Ici, la variable display n'est plus privée, ce qui la rend accessible n'importe où. C'est une mauvaise pratique dans le contexte MVVM car, le View pourrait modifier cette variable, ce qui ne devrait pas etre le cas puisque le View ne doit qu'afficher les changements.
- display = display + number; Ici, le fait de mettre display deux fois allourdit un peu le code.
- Après la modification de la variable display, il n'y a pas de notifyListeners(), ce qui empeche d'envoyer la notification aux abonnés concernant le changement de la variable. C'est une mauvaise pratique dans le contexte MVVM car, le View ne doit pas connaitre la logique. Elle doit juste etre notifiée des changements et mettre à jour l'interface.
- Dans la méthode clearAll() après la mis à jour du display il n'y a pas notifyListeners(), ce qui empeche les abonnés d'etre notifiés du changement de la variable. C'est une mauvaise pratique dans le contexte MVVM car, le View ne doit pas connaitre la logique. Elle doit juste etre notifiée des changements et mettre à jour l'interface.
- Il manque le notifyListeners() à la fin de la méthode calculateResult(), ce qui emepeche les abonnées d'etre notifiés des variables mis à jour. C'est une mauvaise pratique dans le contexte MVVM car, le View n'a pas accès à la logique donc si elle n'est pas notifié elle ne pourra pas mettre à jour l'interface.

**Code corrigé**

```dart
// Fichier : buggy_calculator_viewmodel.dart

import 'package:flutter/material.dart';

class BuggyCalculatorViewModel extends ChangeNotifier {
  String _display = '0';  // Ligne ajustée
  final List<Calculation> _history = [];  // Ligne ajustée

  void inputNumber(String number) {
    if (display == '0') {
      display = number;
    } else {
      display += number;  // Ligne ajustée
    }
    notifyListeners();
    // Ligne ajoutée
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
    notifyListeners();
    // Ligne ajoutée
  }

  void clearAll() {
    display = '0';
    notifyListeners();
    // Ligne ajoutée
  }
}
```

## Partie 3 : Développement

Option 1: Directement dans le code.
