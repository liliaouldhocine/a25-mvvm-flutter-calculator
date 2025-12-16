# Développement — Amélioration de la calculatrice

## Option choisie

**Option 1 : Ajouter la possibilité de calculer les pourcentages (%)**

---

## Respect de l’architecture MVVM

- La logique de calcul est placée dans le ViewModel
- La View se limite à appeler les méthodes du ViewModel
- L’état est exposé à l’aide de getters
- `notifyListeners()` est utilisé après chaque modification d’état
- Le fonctionnement existant de l’application n’est pas modifié

---

## 1. Extension de `CalculatorViewModel`

### Fonctionnalité ajoutée

Le bouton `%` permet de convertir la valeur affichée en pourcentage.

Exemples :

- `50 %` → `0.5`
- `25 %` → `0.25`

### Code ajouté

```dart
void calculatePercentage() {
  try {
    final value = double.parse(_display);
    _display = (value / 100).toString();
  } catch (e) {
    _display = 'Erreur';
  }
  notifyListeners();
}
```

---

## 2. Modification de `CalculatorScreen`

Ajout d’un bouton `%` qui appelle la méthode du ViewModel.

```dart
ElevatedButton(
  onPressed: () => viewModel.calculatePercentage(),
  child: const Text('%'),
),
```

La View ne contient aucune logique de calcul.

---

## 3. Test unitaire — calcul du pourcentage

Test de la logique métier sans interface graphique.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/viewmodels/calculator_viewmodel.dart';

void main() {
  test('calculatePercentage divise la valeur par 100', () {
    final viewModel = CalculatorViewModel();

    viewModel.inputNumber('5');
    viewModel.inputNumber('0');
    viewModel.calculatePercentage();

    expect(viewModel.display, '0.5');
  });
}
```

---

## Instructions pratiques

- Fork du projet fourni
- Création d’une branche : `branche-examen-final`
- Tests effectués sur l’émulateur
- Création d’une Pull Request vers `main`
- La Pull Request n’est pas mergée

---

## Description de la Pull Request

- Nom et prénom : Amine Laarais
- Option choisie : Option 1 — Pourcentage (%)
- Résumé :
  Ajout du calcul des pourcentages en respectant l’architecture MVVM.
  Extension du ViewModel, ajout du bouton `%` et test unitaire.

---

## Conclusion

La fonctionnalité de pourcentage fonctionne correctement et respecte l’architecture MVVM ainsi que les bonnes pratiques Flutter.
