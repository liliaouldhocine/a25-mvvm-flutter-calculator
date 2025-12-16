Question 1 : Architecture MVVM

1. Les trois composants c'est Model, View, ViewModel. Model gère les données comme la classe Calculation qui stocke résultats et ops. View c'est l'UI avec boutons et écran affichage. ViewModel fait le lien, prend inputs des taps et update la View avec nouveaux états.

2. ChangeNotifier dans ViewModel écoute les changements internes, notifyListeners() prévient les widgets qui écoutent pour rebuild seulement ce qui change. Ça évite rebuild tout l'arbre. Alternative en Flutter c'est ValueNotifier, plus simple pour valeurs basiques sans trop de logique.

3. Consumer<CalculatorViewModel> rebuild que la petite partie UI dedans, genre juste le texte display. Provider.of<CalculatorViewModel> prend contexte et rebuild plus large, parfois tout le parent, Consumer c'est optimisé pour perf dans gros widgets.

Question 2 : Séparation des préoccupations

1. Calculation immuable avec tous final, avantage c'est stabilité: une fois calculé, valeurs changent pas par erreur, parfait en MVVM où Model pur et ViewModel reactive sans side effects bizarres.

2. Variables \_display, \_history avec underscore sont privées en Dart, règle "library-private": visibles que dans même fichier/lib, cache implémentation, bon pour encapsulation et éviter accès direct depuis View.

3. Pour Open/Closed sur switch \_pendingOperation, refactor en Map<String, Function(double, double)> ops = {'+': (a,b) => a+b, '-': (a,b)=>a-b}; dans calculateResult() appelle ops[_pendingOperation]!(first, second). Ajoute nouvelle op juste dans map, touche pas méthode.

Question 3 : Comparaison d'architectures

1.  | Approche                         | Avantage                                                                      | Inconvénient                                                                     |
    | -------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
    | setState() StatefulWidget        | Super simple, direct pour petits widgets locaux, rebuild précis ce qu'on veut | Mélange UI et logique dans même classe, dur à tester/maintenir en app complexe   |
    | notifyListeners() ChangeNotifier | Sépare bien préoccupations, ViewModel reusable, scalable pour gros apps MVVM  | Plus de boilerplate avec Provider setup, risque rebuild excessif si pas Consumer |

2.  Migration BLoC: ViewModel → Bloc class, méthodes deviennent Events (ex AddDigitEvent, CalculateEvent), émet States (DisplayState avec history/display). View remplace Consumer par BlocBuilder/BlocListener sur stream states, plus events via BlocProvider.

3.  Dans main.dart, ChangeNotifierProvider(value: CalculatorViewModel()) wrap MaterialApp, rend ViewModel accessible partout via context.read/watch. Omet ça: Provider.of ou Consumer throw erreur "no provider found", View capte null et crash app.
