# **Examen de Développement Flutter - Architecture MVVM**

**Durée :** 2 heures (mais je vous laisse 3 heures)  
**Sujet :** Application Calculatrice avec architecture MVVM  
**Modalités :** Travail individuel, documents autorisés, utilisation d'internet pour documentation officielle uniquement

---

## **Partie 1 : Questions théoriques (30%)**

### **Question 1 : Architecture MVVM**

1. Nommez les trois composants de l'architecture MVVM et décrivez la responsabilité de chacun dans le contexte de l'application calculatrice.
2. Expliquez le rôle de `ChangeNotifier` et `notifyListeners()` dans le ViewModel. Quelle est l'alternative à `ChangeNotifier` dans Flutter ?
3. Pourquoi utilise-t-on `Consumer<CalculatorViewModel>` au lieu de `Provider.of<CalculatorViewModel>` dans certaines parties de la View ?

### **Question 2 : Séparation des préoccupations**

1. La classe `Calculation` dans le dossier `models/` est immuable (tous les champs sont `final`). Quel est l'avantage de cette immutabilité dans le contexte de l'architecture MVVM ?
2. Pourquoi les variables dans `CalculatorViewModel` sont-elles préfixées par un underscore (`_display`, `_history`, etc.) ? Quelle règle de Dart cela respecte-t-il ?
3. Dans `calculator_viewmodel.dart`, la méthode `calculateResult()` contient un `switch` sur `_pendingOperation`. Comment cette logique pourrait-elle être refactorée pour respecter le principe Open/Closed (SOLID) ?

### **Question 3 : Comparaison d'architectures**

1. Comparez l'approche `setState()` de `StatefulWidget` avec l'approche `notifyListeners()` de `ChangeNotifier`. Donnez un avantage et un inconvénient pour chaque approche.
2. Si vous deviez migrer cette application vers une architecture BLoC, quels seraient les principaux changements à apporter au ViewModel ?
3. Expliquez comment `Provider` fonctionne dans `main.dart`. Que se passe-t-il si on omet le `ChangeNotifierProvider` ?

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

1. Identifiez 5 problèmes architecturaux ou techniques dans ce code.
2. Pour chaque problème, expliquez pourquoi c'est une mauvaise pratique dans le contexte MVVM.
3. Réécrivez le code corrigé en respectant l'architecture MVVM et les bonnes pratiques Flutter.
4. Proposez un test unitaire pour la méthode `calculateResult()` qui couvre un cas d'erreur potentiel.

---

## **Partie 3 : Développement (40%)**

### **Consigne :**

Améliorez l'application calculatrice existante en ajoutant **une seule** des fonctionnalités suivantes. Choisissez la fonctionnalité qui correspond à votre numéro d'étudiant modulo 4 :

- **Option 0** : Ajouter un bouton "M+" (Mémoire Add) et "MR" (Memory Recall) avec une mémoire simple
- **Option 1** : Ajouter la possibilité de calculer les pourcentages (bouton "%")
- **Option 2** : Ajouter un historique des 5 derniers calculs affiché directement sur l'écran principal
- **Option 3** : Ajouter un mode "nuit" avec un thème sombre activable/désactivable

### **Exigences techniques :**

1. Respectez scrupuleusement l'architecture MVVM existante
2. Créez de nouveaux fichiers si nécessaire, mais ne modifiez pas le fonctionnement existant
3. Utilisez des getters appropriés pour exposer les nouveaux états
4. Ajoutez des commentaires expliquant vos choix architecturaux
5. Testez votre fonctionnalité sur l'émulateur avant la fin de l'examen

### **Structure attendue :**

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