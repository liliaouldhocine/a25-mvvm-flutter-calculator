# **Parallèle détaillé : MVC vs MVVM dans Flutter**

## **1. Vue d'ensemble des deux architectures**

```
MVC (Model-View-Controller)           MVVM (Model-View-ViewModel)
┌─────────────────────────┐          ┌─────────────────────────┐
│         CONTROLLER      │          │       VIEWMODEL         │
│  (StatefulWidget)       │          │  (ChangeNotifier/Bloc)  │
│                         │          │                         │
│  - Gère état            │          │  - Gère état            │
│  - Gère logique         │          │  - Gère logique         │
│  - Appelle setState()   │          │  - Notifie via streams  │
└───────────┬─────────────┘          └───────────┬─────────────┘
            │                                    │
┌───────────▼─────────────┐          ┌───────────▼─────────────┐
│           VIEW          │          │           VIEW          │
│   (Build method UI)     │          │   (StatelessWidget)     │
│                         │          │                         │
│  - Affiche données      │          │  - Affiche données      │
│  - Capture événements   │          │  - Capture événements   │
└───────────┬─────────────┘          └───────────┬─────────────┘
            │                                    │
┌───────────▼─────────────┐          ┌───────────▼─────────────┐
│          MODEL          │          │          MODEL          │
│   (Classes de données)  │          │   (Classes de données)  │
│                         │          │                         │
│  - Structure données    │          │  - Structure données    │
│  - Pas de logique       │          │  - Pas de logique       │
└─────────────────────────┘          └─────────────────────────┘
```

## **2. MÊME APPLICATION (Calculatrice) dans les deux architectures**

### **VERSION MVC (Approche traditionnelle Flutter)**

#### **Model - Identique dans les deux**

```dart
// calculation.dart - EXACTEMENT LE MÊME
class Calculation {
  final String expression;
  final double result;
  final DateTime timestamp;

  Calculation(this.expression, this.result, this.timestamp);
}
```

#### **Controller = StatefulWidget**

```dart
// calculator_controller.dart - MVC
import 'package:flutter/material.dart';
import '../models/calculation.dart';

class CalculatorController extends StatefulWidget {
  const CalculatorController({super.key});

  @override
  State<CalculatorController> createState() => _CalculatorControllerState();
}

class _CalculatorControllerState extends State<CalculatorController> {
  // ÉTAT mélangé avec logique
  String _display = '0';
  String _currentInput = '';
  String _pendingOperation = '';
  double _storedValue = 0;
  final List<Calculation> _history = [];

  // LOGIQUE MÉTIER directement dans le contrôleur
  void _inputNumber(String number) {
    setState(() {  // setState() mélange UI et logique
      if (_display == '0' || _pendingOperation.isNotEmpty) {
        _display = number;
      } else {
        _display += number;
      }
      _currentInput = _display;
    });
  }

  void _calculateResult() {
    setState(() {
      double currentValue = double.parse(_currentInput);
      double result = 0;

      switch (_pendingOperation) {
        case '+': result = _storedValue + currentValue; break;
        // ...
      }

      _history.add(Calculation(
        expression: '$_storedValue $_pendingOperation $currentValue',
        result: result,
        timestamp: DateTime.now(),
      ));

      _display = result.toString();
      _resetCalculator();
    });
  }

  void _resetCalculator() {
    _currentInput = '';
    _pendingOperation = '';
    _storedValue = 0;
  }

  // BUILD = VIEW mélangée avec contrôleur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculatrice MVC')),
      body: Column(
        children: [
          // AFFICHAGE
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              child: Text(
                _display,  // Accès DIRECT à l'état
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          // BOUTONS
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                ElevatedButton(
                  onPressed: () => _inputNumber("5"),  // Appel DIRECT
                  child: const Text("5"),
                ),
                // ...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### **Problèmes du MVC :**

1. **Logique + UI dans la même classe**
2. **`setState()` partout**
3. **Difficile à tester**
4. **Réutilisabilité faible**

### **VERSION MVVM (Notre implémentation)**

#### **Model - Identique**

```dart
// Même fichier que MVC
```

#### **ViewModel - Séparé**

```dart
// calculator_viewmodel.dart - MVVM
class CalculatorViewModel extends ChangeNotifier {
  // ÉTAT seulement
  String _display = '0';
  // ...

  // LOGIQUE seulement
  void inputNumber(String number) {
    // Logique pure, pas de setState()
    if (_display == '0' || _pendingOperation.isNotEmpty) {
      _display = number;
    } else {
      _display += number;
    }
    _currentInput = _display;
    notifyListeners();  // Notification découplée
  }

  // Pas de code UI du tout
}
```

#### **View - Stateless et propre**

```dart
// calculator_screen.dart - MVVM
class CalculatorScreen extends StatelessWidget {  // Stateless !
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculatorViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          // AFFICHAGE (dépend du ViewModel)
          Expanded(
            child: Consumer<CalculatorViewModel>(
              builder: (context, viewModel, child) {
                return Text(viewModel.display);  // Données via ViewModel
              },
            ),
          ),
          // BOUTONS (délégation au ViewModel)
          ElevatedButton(
            onPressed: () => viewModel.inputNumber("5"),  // Délégation
            child: const Text("5"),
          ),
        ],
      ),
    );
  }
}
```

## **3. TABLEAU COMPARATIF DÉTAILLÉ**

| Aspect              | MVC (Flutter traditionnel)      | MVVM (Notre implémentation)        |
| ------------------- | ------------------------------- | ---------------------------------- |
| **Type de Widget**  | `StatefulWidget`                | `StatelessWidget`                  |
| **Gestion d'état**  | `setState()` dans le contrôleur | `notifyListeners()` dans ViewModel |
| **Séparation**      | Contrôleur + View mélangés      | View ↔ ViewModel ↔ Model clairs    |
| **Testabilité**     | Difficile (UI mélangée)         | Facile (ViewModel testable seul)   |
| **Réutilisabilité** | Faible (couplage fort)          | Forte (ViewModel réutilisable)     |
| **Équipe**          | Développeur full-stack          | UI Designer + Logic Developer      |
| **Évolution**       | Devient spaghetti rapidement    | Scalable, maintenable              |
| **Hot Reload**      | Rebuild complet                 | Rebuild partiel (Consumer)         |
| **Code typique**    | 500+ lignes dans une classe     | 3 fichiers de 100-150 lignes       |
| **Dépendances**     | Aucune (Flutter pur)            | Provider/Riverpod/Bloc             |

## **4. FLUX DE DONNÉES COMPARÉ**

### **MVC Flux :**

```
Utilisateur → View → Controller (setState) → View rebuild
      ↓
  Logique métier
      ↓
  Accès direct Model
```

### **MVVM Flux :**

```
Utilisateur → View → ViewModel (notify) → View (Consumer rebuild)
      ↓          ↓            ↓
     Événement  Délégation   Logique
                        ↓
                      Model (via ViewModel)
```

## **5. EXEMPLE CONCRET : Ajouter une fonctionnalité**

### **Scénario : Ajouter un historique des calculs**

#### **En MVC :**

```dart
// Dans CalculatorController (déjà 200+ lignes)
void _showHistory() {
  showDialog(
    context: context,  // Besoin de context dans le contrôleur
    builder: (context) => AlertDialog(
      title: const Text('Historique'),
      content: Column(
        children: _history.map((calc) => Text(calc.expression)).toList(),
      ),
    ),
  );
}

// Appel dans build() - plus de mélange
ElevatedButton(
  onPressed: _showHistory,  // Logique UI dans contrôleur
  child: const Text('Historique'),
)
```

#### **En MVVM :**

```dart
// ViewModel - Logique pure
List<Calculation> get history => List.unmodifiable(_history);

// View - UI pure, navigation séparée
ElevatedButton(
  onPressed: () {
    Navigator.push(  // Navigation dans la View
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  },
  child: const Text('Historique'),
)

// Nouvel écran HistoryScreen - Réutilise le même ViewModel
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculatorViewModel>(context);
    return Scaffold(
      body: ListView(
        children: viewModel.history.map((calc) =>
          ListTile(title: Text(calc.expression))
        ).toList(),
      ),
    );
  }
}
```

## **6. TESTABILITÉ COMPARÉE**

### **Test MVC (Complexe)**

```dart
void testMvcCalculator() {
  // Doit tester un Widget entier
  testWidgets('MVC Calculator', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorController());
    await tester.tap(find.text('5'));
    await tester.pump();
    // Vérification complexe de l'UI
    expect(find.text('5'), findsOneWidget);
  });
}
```

### **Test MVVM (Simple)**

```dart
void testMvvmCalculator() {
  // Test unitaire pur, pas d'UI
  test('MVVM Calculator logic', () {
    final viewModel = CalculatorViewModel();
    viewModel.inputNumber('5');
    expect(viewModel.display, '5');

    viewModel.setOperation('+');
    viewModel.inputNumber('3');
    viewModel.calculateResult();

    expect(viewModel.display, '8');
    expect(viewModel.history.length, 1);
  });
}
```

## **7. ÉVOLUTION À LONG TERME**

### **MVC après 6 mois :**

```
CalculatorController (1200 lignes)
├── 15 variables d'état
├── 40 méthodes de logique
├── Build() de 300 lignes
├── Mix navigation + UI + logique
└── Impossible à diviser
```

### **MVVM après 6 mois :**

```
lib/
├── models/
│   ├── calculation.dart (50 lignes)
│   └── settings.dart (30 lignes)
├── viewmodels/
│   ├── calculator_viewmodel.dart (200 lignes)
│   ├── history_viewmodel.dart (100 lignes)
│   └── settings_viewmodel.dart (80 lignes)
├── views/
│   ├── calculator_screen.dart (150 lignes)
│   ├── history_screen.dart (100 lignes)
│   └── settings_screen.dart (120 lignes)
└── services/
    ├── storage_service.dart
    └── api_service.dart
```

## **8. QUAND CHOISIR QUOI ?**

### **Choisir MVC si :**

- Application très simple (< 3 écrans)
- Prototype rapide
- Développeur seul
- Pas besoin de tests unitaires

### **Choisir MVVM si :**

- Application moyenne à complexe
- Travail en équipe
- Tests unitaires requis
- Maintenance à long terme
- Réutilisabilité souhaitée

## **9. CODE SIDE-BY-SIDE**

### **Gestion d'un clic :**

```dart
// MVC
onPressed: () {
  setState(() {  // Mélange UI/logique
    if (_display == '0') _display = '5';
    else _display += '5';
  });
}

// MVVM
onPressed: () => viewModel.inputNumber('5')  // Délégation pure
```

### **Accès aux données :**

```dart
// MVC
Text(_display)  // Accès direct à l'état

// MVVM
Consumer<CalculatorViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.display);  // Via ViewModel
  }
)
```

## **10. CONCLUSION**

**MVC** = Comme cuisiner dans une seule casserole :

- Tout mélangé
- Rapide au début
- Difficile à nettoyer
- Impossible de réutiliser des ingrédients

**MVVM** = Comme une cuisine professionnelle :

- Zone préparation (ViewModel)
- Zone cuisson (Model)
- Zone service (View)
- Chaque ingrédient réutilisable
- Plusieurs cuisiniers peuvent travailler
