# Examen Flutter MVVM — Réponses théoriques

## Question 1 (MVVM)

1. MVVM :

- Model :
  - Contient les données pures (ex : Calculation: expression, résultat, timestamp).
  - Pas de logique UI, pas de notifyListeners.
- ViewModel :

  - Contient l'état (ex: \_display, \_history, opérations en cours) + la logique métier (calcul, règles).
  - Notifier la vue avec notifyListeners().

- View :
  - Contient l' interface (widgets, layout, boutons) + navigation.
  - Ne fait pas de calcul : elle appelle le ViewModel (ex: inputNumber, setOperation, calculateResult).

2. ChangeNotifier / notifyListeners :

- Rôle :
  - **ChangeNotifier**: C'est un objet observable. La View s'abonne via Fournisseur/Consommateur.
  - **notifyListeners()**: Appelé quand l'état change, pour demander aux Widgets qui écoutent de se reconstruire (rebuild) avec les nouvelles valeurs.
  - **Alternative** : Exemple : BLoC/Cubit , ou Riverpod (StateNotifier/Notifier) ​​, ou même ValueNotifier (plus simple).

3. Consumer vs Provider.of :

- Consumer permet de limiter les reconstructions : seul le widget dans le builder se reconstruit lorsque le ViewModel change.
- Provider.of(context)peut provoquer une reconstruction plus grande si utilisé haut dans l'arbre (moins optimisé).

##  Question 2 (Séparation)

1. Immutabilité de Calculation :

- Avantage : Les objets d'historique sont stables : une fois créés, ils ne changent pas.
- Ça rend l'état plus prévisible , facilite le débogage, et évite les bugs liés à des modifications inattendues.

2. Pourquoi underscore (\_display, \_history) :

- Règle Dart : rend un attribut privé au niveau de la librairie .
- Ça protège l'état : la View ne peut pas le modifier directement → elle passe par des méthodes du ViewModel (meilleure séparation MVVM).

3. Refactor du switch (Open/Closed) :

- Problème du switch : à chaque nouvelle opération tu dois modifier la méthode (donc pas « fermé »).
- Solution possible (stratégie / map) :
    - ex:Map<String, double Function(double, double)> operations
    - Ajouter une opération devient « ajouter une entrée dans la carte » sans modifier la logique principale.
## QUESTION 3 : COMPARAISON D'ARCHITECTURES
1. setState vs notifyListeners : un avantage + un inconvénient

### définirÉtat (Widget à état)

- avantage :simple et rapide pour les petits écrans.
- inconvénient: logique souvent mélangée à l'UI, test moins facile, reconstruction parfois large
### ChangeNotifier + notifyListeners

- Avantage: logique séparée dans le ViewModel, plus testable et réutilisable

- inconvénient:  si mal structuré, peut reconstruire trop de widgets, et nécessite une bonne organisation

2. Si migration vers BLoC : changements principaux au ViewModel ?

- Le ViewModel devient un Bloc/Cubit :

    - au lieu d'un état mutable + notifyListeners, on émet des States .

    - l'UI réagit via BlocBuilder/ BlocListener.

- La logique devient pilotée par Events (Bloc) ou des méthodes qui émettent des états (Cubit).

3. Comment Provider fonctionne dans main.dart ? Et si sur ChangeNotifierProvider ?

- ChangeNotifierProvider crée et injecte le ViewModel dans l'arbre Widget.

- Ensuite la View peut faire Provider.of/ Consumer/ context.watch.

- Si on l'oublie : la View ne trouve pas le ViewModel → erreur du type ProviderNotFoundException / « No Provider found… ».