# Questions Théoriques - MVVM

## Question 1 : Les trois composants de l'architecture MVVM

### 1. Model (Modèle)
- **Responsabilité** : Contient la logique métier et les données
- **Dans la calculatrice** : Gère les calculs mathématiques (addition, soustraction, multiplication, division) et stocke les valeurs/résultats

### 2. View (Vue)
- **Responsabilité** : Affiche l'interface utilisateur et capture les interactions de l'utilisateur
- **Dans la calculatrice** : Les boutons (0-9, +, -, ×, ÷, =, C) et l'écran d'affichage du résultat

### 3. ViewModel (Vue-Modèle)
- **Responsabilité** : Fait le lien entre le Model et la View, expose les données via des bindings et gère l'état de l'UI
- **Dans la calculatrice** : Reçoit les appuis de boutons, appelle le Model pour effectuer les calculs, et notifie la View pour mettre à jour l'affichage

---

**2 : ChangeNotifier et notifyListeners()**

### Rôle de ChangeNotifier
`ChangeNotifier` est une classe fournie par Flutter qui implémente le pattern Observable. Le ViewModel hérite de cette classe pour pouvoir notifier la View des changements d'état.

### Rôle de notifyListeners()
`notifyListeners()` est une méthode de `ChangeNotifier` qui :
- Déclenche une notification à tous les widgets écouteurs (listeners)
- Provoque la reconstruction (rebuild) des widgets qui dépendent des données modifiées
- Permet la mise à jour automatique de l'interface utilisateur

**Exemple dans une calculatrice :**
```dart
class CalculatorViewModel extends ChangeNotifier {
  String _result = "0";
  
  String get result => _result;
  
  void calculate(String expression) {
    _result = // ... calcul
    notifyListeners(); // Notifie la View de mettre à jour l'affichage
  }
}
```

### Alternatives à ChangeNotifier dans Flutter
1. **Riverpod** - Gestion d'état moderne et type-safe
2. **Bloc/Cubit** - Pattern basé sur les streams et événements
3. **GetX** - Solution légère avec réactivité intégrée
4. **ValueNotifier** - Version simplifiée pour une seule valeur
5. **InheritedWidget** - Mécanisme natif de Flutter (bas niveau)

---

**3. Pourquoi utiliser Consumer<CalculatorViewModel>** 
Consumer reconstruit uniquement le widget concerné, pas tout le parent

- Il est plus performant grâce à des rebuilds ciblés

- Il rend le code plus lisible en montrant clairement quelle partie dépend du ViewModel

En pratique :
- Utilise Consumer quand une partie précise de l’UI doit se mettre à jour

- Utilise Provider.of(context, listen: false) pour appeler des méthodes sans déclencher de rebuild

## Question 2 : Séparation des préoccupations
### 1. Avantages de l'immutabilité dans MVVM
**Prévisibilité :** L'état ne peut pas être modifié accidentellement, ce qui évite les bugs liés aux mutations inattendues

**Traçabilité :** Chaque changement crée un nouvel objet → facilite le débogage et l'historique des états

**Thread-safety :** Pas de problèmes de concurrence car l'objet ne change jamais après sa création

**Détection des changements simplifiée :** Le ViewModel peut comparer les références d'objets pour savoir si une mise à jour est nécessaire

**Cohérence avec notifyListeners() :** Encourage la création de nouveaux objets plutôt que la mutation, ce qui garantit que les listeners sont notifiés correctement

### 2.Le préfixe underscore (_) en Dart
**Signification**
Le underscore (_) rend la variable privée au niveau de la bibliothèque (fichier).

**Règle Dart respectée**
C'est la convention d'encapsulation de Dart : contrairement à d'autres langages (Java, C#), Dart n'a pas de mot-clé private. Le _ est le mécanisme natif pour rendre un membre inaccessible depuis l'extérieur du fichier.

### 3.Refactoring pour le principe Open/Closed
La méthode calculateResult() utilise un switch, ce qui viole le principe Open/Closed car chaque nouvelle opération nécessite une modification du code.
On peut refactorer cette logique en utilisant le pattern Strategy avec une Map d’opérations. Ainsi, calculateResult() reste inchangée et l’ajout d’une nouvelle opération se fait simplement en ajoutant une entrée dans la Map, respectant le principe Open/Closed.
## Question 3 : Comparaison d'architectures
### 1.Comparaison setState() vs notifyListeners()
**setState() :** gère un état local dans un widget, simple et rapide, mais mélange UI et logique, peu adapté aux apps complexes.

**notifyListeners() :** gère un état partagé via Provider, avec une séparation View / ViewModel, plus propre et testable, mais plus verbeux.

**En pratique :**

- setState() → petits widgets simples
- notifyListeners() → applications avec état partagé et architecture MVVM
### 2.Migration MVVM → BLoC :

**ChangeNotifier → Bloc/Cubit :** on remplace notifyListeners() par emit(newState)

**État mutable → états immutables :** création de classes State avec copyWith()

**Actions → Events** (pour Bloc complet) ou méthodes directes (Cubit)

**View :** Consumer devient BlocBuilder

**Injection :** Provider devient BlocProvider

BLoC apporte une gestion d’état plus structurée, prévisible et scalable, au prix de plus de code qu’en MVVM.
### 3.Fonctionnement de Provider dans main.dart
**ChangeNotifierProvider** dans main.dart crée une instance unique du CalculatorViewModel et l’injecte dans l’arbre de widgets.
Tous les widgets descendants peuvent y accéder via Consumer ou Provider.of, et ils sont reconstruits quand notifyListeners() est appelé.

Sans ChangeNotifierProvider :

Consumer et Provider.of ne trouvent pas le ViewModel

Une ProviderNotFoundException est levée

L’application crash

**Analogie :**
ChangeNotifierProvider = prise électrique, Consumer = appareil.
Sans prise, rien ne fonctionne

# Partie 2 : Correction de code 
## 1. Les 5 problèmes architecturaux / techniques
  -1 Oubli de notifyListeners()

Les méthodes inputNumber(), calculateResult() et clearAll() modifient l’état
Aucun appel à notifyListeners() → l’UI ne se met pas à jour

  -2 Attributs publics modifiables

String display;
List<String> history;
Violent l’encapsulation
N’importe quel widget peut modifier l’état sans contrôle
Devraient être private (_display, _history) avec getters

  -3 Logique métier fragile et non extensible

if (display.contains('+')) { ... }
Couplage fort au format texte
Impossible de gérer -, ×, ÷, priorités, ou plusieurs opérations
Ne respecte pas Open/Closed

  -4 Risque élevé d’erreurs à l’exécution

double.parse(parts[0])

Aucun contrôle d’erreur (try/catch)
Crash possible si l’entrée est invalide ("1+", "+", "abc")
Responsabilités mélangées (SRP violé)

  -5 Le ViewModel :
gère l’affichage (display)
parse une expression
effectue le calcul
gère l’historique
Trop de responsabilités → difficile à tester et maintenir

## 2. Mauvaise pratique dans le contexte MVVM.
**Pas de notifyListeners() :** la View n’est pas informée des changements → UI désynchronisée.

**État public :** l’UI peut modifier le ViewModel directement → perte d’encapsulation.

**Logique basée sur display :** couplage fort entre UI et logique métier → MVVM violé.

**Aucune gestion d’erreurs :** entrées invalides peuvent faire crasher l’app → View non protégée.

**Trop de responsabilités :** calcul, parsing et affichage mélangés → code difficile à maintenir et tester.

En MVVM, le ViewModel doit être observable, encapsulé, découplé de l’UI et focalisé.

## 3. corrigé du code 

```dart


import 'package:flutter/material.dart';

class CalculatorViewModel extends ChangeNotifier {
  // État privé (encapsulation)
  String _display = '0';
  final List<String> _history = [];

  //  Getters exposés à la View
  String get display => _display;
  List<String> get history => List.unmodifiable(_history);

  //  Gestion des entrées utilisateur
  void inputNumber(String number) {
    if (_display == '0') {
      _display = number;
    } else {
      _display += number;
    }
    notifyListeners();
  }

  //  Logique métier simple (séparée de l’UI)
  void calculateResult() {
    try {
      if (_display.contains('+')) {
        final parts = _display.split('+');

        if (parts.length == 2) {
          final a = double.parse(parts[0]);
          final b = double.parse(parts[1]);

          final result = a + b;
          _display = result.toString();
          _history.add(_display);
        }
      }
    } catch (e) {
      _display = 'Erreur';
    }

    notifyListeners();
  }

  //  Réinitialisation de l’état
  void clearAll() {
    _display = '0';
    notifyListeners();
  }
}
```
### 4 .test unitaire
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/viewmodels/calculator_viewmodel.dart';

void main() {
  test('calculateResult affiche "Erreur" si le calcul échoue', () {
    // Arrange
    final viewModel = CalculatorViewModel();

    // Simule un état invalide (expression incorrecte)
    viewModel.inputNumber('a');
    viewModel.inputNumber('+');
    viewModel.inputNumber('1');

    // Act
    viewModel.calculateResult();

    // Assert
    expect(viewModel.display, 'Erreur');
  });
}
```
# Partie 3 : Développement
num etudiante :2496293%4 = 1
Option 1 : Ajouter la possibilité de calculer les pourcentages (bouton "%")

![Capture d'écran](/examen-final/capture.png)