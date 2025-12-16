# **Examen de Développement Flutter - Architecture MVVM**

## **Partie 1 : Questions théoriques (30%)**

### **Question 1 : Architecture MVVM**

**1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.**

**Réponse :**
- **Model** : La classe `Calculation` qui contient les données immuables (expression, result, timestamp). Le Model stocke juste les données.
- **ViewModel** : La classe `CalculatorViewModel` qui hérite de `ChangeNotifier`. Elle contient toute la logique des opérations (les méthodes `inputNumber()`, `calculateResult()`, `setOperation()`).
- **View** : Les fichiers `calculator_screen.dart` et `history_screen.dart`. La View affiche l'écran et les boutons, mais ne contient pas la logique.

Chaque composant a sa responsabilité propre : le Model stocke les données, le ViewModel gère la logique, la View affiche.

**2. Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est l'alternative à `ChangeNotifier` dans Flutter ?**

**Réponse :**

`ChangeNotifier` est la classe parent du `CalculatorViewModel`. Elle permet au ViewModel de notifier la View quand l'état change. `notifyListeners()` est la méthode qu'on appelle quand une variable change (comme `_display` ou `_history`). Cette méthode dit à la View de se redessiner.

Les alternatives à `ChangeNotifier` sont : `ValueNotifier` (plus simple, pour une seule valeur) ou `BLoC` (plus complexe, avec des streams). 

**3. Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?**

**Réponse :**

`Consumer` est un widget qui écoute les changements du ViewModel et redessine automatiquement. Avec `Consumer`, seulement la partie qui change redessine. `Provider.of` accède au ViewModel mais ne redessine pas automatiquement. Il faut ajouter `listen: false` ou `listen: true` manuellement. Dans `calculator_screen.dart`, on utilise `Consumer` autour de la partie qui affiche `display` parce qu'elle doit se mettre à jour à chaque changement.

### **Question 2 : Séparation des préoccupations**

**1. La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?**

**Réponse :**

Parce que les champs sont `final`, on ne peut pas les changer après la création. L'historique des calculs reste sûr et ne peut pas être modifié par accident. Les tests deviennent plus faciles parce qu'on sait que les données ne changent pas. On peut prédire le résultat du test. Cela respecte aussi le Model dans MVVM : le Model doit être une représentation pure et immuable des données.

**2. Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?**

**Réponse :**

L'underscore `_` rend les variables privées en Dart. Les variables comme `_display` et `_history` sont accessibles seulement à l'intérieur du fichier `calculator_viewmodel.dart`. Cela respecte le principe d'encapsulation. La View ne peut pas modifier directement `_display`. Elle doit passer par le getter public `display` ou les méthodes publiques. C'est une protection pour respecter MVVM : la View ne doit jamais accéder directement aux données privées du ViewModel.

**3. Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?**

**Réponse :**

Actuellement, le `switch` contient tous les cas (+, -, ×, ÷). Si on veut ajouter une nouvelle opération, il faut modifier la méthode existante. Le principe Open/Closed dit qu'il faut ajouter des nouvelles fonctionnalités sans modifier le code existant. Une solution simple est d'utiliser une Map avec les opérations comme fonctions : `{'+': (a, b) => a + b, '-': (a, b) => a - b}`. Ajouter une opération devient juste ajouter une ligne à la Map. Une autre solution est le pattern Strategy : créer une classe abstraite `Operation` et une sous-classe pour chaque opération.

### **Question 3 : Comparaison d'architectures**

**1. Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.**

**Réponse :**

**setState() :**
- Avantage : très simple, pas besoin de package externe. Le code est court et facile à comprendre.
- Inconvénient : redessine tout le widget et ses enfants, même les parts qui ne changent pas. C'est inefficace pour les grandes applications.

**notifyListeners() :**
- Avantage : sépare la logique de la View. Redessine seulement les widgets qui écoutent le changement. Meilleure performance.
- Inconvénient : plus de code à écrire. Il faut utiliser le package Provider et comprendre comment ça fonctionne.

**2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?**

**Réponse :**

Au lieu de `ChangeNotifier`, le ViewModel deviendrait un `Bloc` qui utilise des Streams. Les méthodes publiques comme `inputNumber()` deviendraient des événements : on ferait `add(NumberInputEvent('5'))` au lieu d'appeler directement la méthode. La Vue utiliserait `BlocBuilder` au lieu de `Consumer` pour écouter les changements. La logique transformerait les événements en états avec une méthode `mapEventToState()`. En résumé : le modèle passe d'un système de variables observables à un système d'événements et d'états.

**3. Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?**

**Réponse :**

Dans `main.dart`, le `ChangeNotifierProvider` crée une instance du `CalculatorViewModel` et la rend disponible à tous les enfants de l'arbre de widgets. Les écrans comme `CalculatorScreen` peuvent accéder au ViewModel avec `Consumer` ou `Provider.of` grâce au Provider. Si on omet le `ChangeNotifierProvider`, il n'y a pas de ViewModel dans l'arbre. Les enfants lancent une erreur : "could not find a CalculatorViewModel in this context". L'application ne fonctionne plus parce que la View ne peut pas accéder à la logique du ViewModel.