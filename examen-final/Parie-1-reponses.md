# Réponses - Examen final
# Réponses – Examen final

Partie 1

## Question 1 — Architecture MVVM

### 1) Les trois composants de l’architecture MVVM et leur responsabilité

- **Model**
  - Représente les données et la logique métier.
  - Dans l’application calculatrice, il contient les valeurs manipulées (opérandes, opérateurs, résultat) et les règles de calcul.
  - Il est indépendant de l’interface utilisateur.

- **View**
  - Correspond à l’interface utilisateur (écran de la calculatrice, boutons, affichage).
  - Elle affiche l’état fourni par le ViewModel et transmet les actions de l’utilisateur (clics sur les boutons).
  - Elle ne contient pas de logique de calcul.

- **ViewModel**
  - Sert d’intermédiaire entre la View et le Model.
  - Il contient l’état de l’interface (ex. valeur affichée) et les méthodes appelées par la View.
  - Il met à jour les données et notifie la View lorsqu’un changement survient.

---

### 2) Rôle de `ChangeNotifier` et `notifyListeners()` et alternative

- **ChangeNotifier**
  - Permet au ViewModel d’être écouté par la View.
  - Il implémente le principe d’observateur pour signaler les changements d’état.

- **notifyListeners()**
  - Est appelé lorsqu’une donnée du ViewModel change.
  - Il informe toutes les Views à l’écoute afin qu’elles se reconstruisent et affichent les nouvelles valeurs.

- **Alternative à ChangeNotifier**
  - Une alternative simple est `ValueNotifier` combiné à `ValueListenableBuilder`.
  - D’autres alternatives existent selon l’architecture choisie, comme Bloc/Cubit ou Riverpod.

---

### 3) Pourquoi utiliser `Consumer<CalculatorViewModel>` plutôt que `Provider.of<CalculatorViewModel>` ?

- **Consumer**
  - Permet de reconstruire uniquement la partie du widget qui dépend du ViewModel.
  - Améliore les performances en évitant des reconstructions inutiles de toute la View.

- **Provider.of**
  - Peut provoquer la reconstruction complète du widget si `listen` est à `true`.
  - Il est souvent utilisé avec `listen: false` pour appeler une méthode sans déclencher de reconstruction.

- **Conclusion**
  - `Consumer` est utilisé lorsque l’interface doit réagir aux changements d’état.
  - `Provider.of` est privilégié pour accéder au ViewModel sans écoute ou pour des actions ponctuelles.

  

  ## Question 2 — Séparation des préoccupations

### 1) Avantage de l’immutabilité de la classe Calculation

La classe Calculation est immuable car tous ses champs sont `final`. Cela garantit que l’état d’une opération ne peut pas être modifié après sa création. Dans l’architecture MVVM, cela rend les données plus prévisibles, évite les effets de bord et facilite le débogage ainsi que les tests. Chaque modification correspond à une nouvelle instance, ce qui renforce la séparation entre le Model et le ViewModel.

---

### 2) Préfixe `_` dans CalculatorViewModel

Les variables comme `_display` ou `_history` sont préfixées par `_` afin de les rendre privées au niveau du fichier. Cette règle de Dart permet d’appliquer le principe d’encapsulation. L’état interne du ViewModel ne peut pas être modifié directement depuis la View et est exposé uniquement via des getters ou des méthodes contrôlées.

---

### 3) Respect du principe Open/Closed dans calculateResult()

La méthode `calculateResult()` utilise un `switch` sur `_pendingOperation`, ce qui oblige à modifier le code pour ajouter une nouvelle opération. Pour respecter le principe Open/Closed, cette logique pourrait être refactorisée en utilisant le pattern Strategy ou une map d’opérations. Chaque opération serait définie séparément, permettant d’en ajouter de nouvelles sans modifier la méthode existante, rendant le code plus extensible et maintenable.


## Question 3 — Comparaison d’architectures

### 1) setState() (StatefulWidget) vs notifyListeners() (ChangeNotifier)

**setState()**
- **Avantage :** Simple et rapide à utiliser pour de petits écrans : la mise à jour de l’UI est directe dans le widget.
- **Inconvénient :** La logique et l’état restent souvent collés à la View, ce qui peut rendre le code moins maintenable/testable quand l’app grandit.

**notifyListeners() (ChangeNotifier)**
- **Avantage :** Sépare mieux l’état et la logique de l’UI (MVVM), facilite la réutilisation et les tests du ViewModel.
- **Inconvénient :** Ajoute une couche (Provider/ViewModel) et peut provoquer des reconstructions si on n’isole pas bien les widgets (mauvaise granularité).

---

### 2) Migration vers une architecture BLoC : principaux changements

- Remplacer le ViewModel (ChangeNotifier + variables privées) par :
  - des **Events** (ex. DigitPressed, OperatorPressed, ClearPressed, EqualsPressed)
  - des **States** (ex. display, history, pendingOperation, etc.)
  - un **Bloc** (ou Cubit) qui reçoit des events et émet des states.
- La View n’appelle plus des méthodes du ViewModel directement : elle **dispatch** des events.
- La View n’écoute plus notifyListeners() : elle utilise **BlocBuilder/BlocListener** (ou StreamBuilder selon l’implémentation).
- L’état devient généralement **immutable** (nouveau state à chaque changement).

---

### 3) Fonctionnement de Provider dans main.dart et effet si on omet ChangeNotifierProvider

- Dans `main.dart`, `ChangeNotifierProvider` crée et fournit une instance de `CalculatorViewModel` à tout le widget tree (souvent au-dessus de `MaterialApp` ou de l’écran principal).
- Les widgets enfants récupèrent ce ViewModel via `Consumer<CalculatorViewModel>` ou `Provider.of<CalculatorViewModel>(context)`.

**Si on omet `ChangeNotifierProvider` :**
- Le ViewModel n’est plus disponible dans l’arbre de widgets.
- Toute tentative d’accès (`Consumer` / `Provider.of`) provoque une erreur du type :
  - **ProviderNotFoundException** (aucun provider trouvé dans le contexte).
- L’application ne peut pas réagir aux changements d’état car il n’y a plus de source (ViewModel) injectée.

