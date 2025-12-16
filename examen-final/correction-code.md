# Partie 2 — Correction de code

## 1) 5 problèmes trouvés
1. notifyListeners()
2. ÉTAT PUBLIC
3. Analyse fragile de l'expression (split « + »)
4. Gestion d'erreurs inexistantes
5. Historique mal modélisé

## 2) Pourquoi c’est mauvais en MVVM
- Encapsulation : "La View ne doit pas pouvoir modifier l'état directement; elle appelle des méthodes du ViewModel."

- notifyListeners : "Sans notifyListeners(), la View n'est pas notifiée et l'affichage peut rester bloqué."

- Parsing fragile : "La logique dépend d'un format de chaîne instable; une entrée invalide peut faire planter l'application."

- Pas de validation : « Un ViewModel doit gérer les cas limites et éviter les exceptions. »

- Historique : « Les données doivent être structurées via un Modèle immuable ; sinon c'est difficile à maintenir/tester. »

## 3) Réécriture (principe)
- Etat privé + getters
- notifyListeners au bon moment
- Historique avec Model Calculation
- Gestion d’erreurs 
````dart
// calculator_viewmodel.dart
class CalculatorViewModel extends ChangeNotifier {
  String _display = '0';
  final List<String> _history = [];
  String? _pendingOperation;
  double? _firstNumber;
  double? _memory;

  String get display => _display;
  List<String> get history => List.unmodifiable(_history);
  double? get memory => _memory;

  void inputNumber(String number) {
    if (_display == '0' || _pendingOperation != null) {
      _display = number;
    } else {
      _display += number;
    }
    _pendingOperation = null;
    notifyListeners();
  }

  void setOperation(String operation) {
    _firstNumber = double.parse(_display);
    _pendingOperation = operation;
    notifyListeners();
  }

  void calculateResult() {
    if (_firstNumber == null || _pendingOperation == null) return;
    
    try {
      final secondNumber = double.parse(_display);
      double result;
      
      switch (_pendingOperation) {
        case '+':
          result = _firstNumber! + secondNumber;
          break;
        case '-':
          result = _firstNumber! - secondNumber;
          break;
        case '*':
          result = _firstNumber! * secondNumber;
          break;
        case '/':
          if (secondNumber == 0) throw Exception('Division par zéro');
          result = _firstNumber! / secondNumber;
          break;
        default:
          throw Exception('Opération non supportée');
      }
      
      _history.add('${_firstNumber} $_pendingOperation $secondNumber = $result');
      if (_history.length > 5) _history.removeAt(0);
      
      _display = _formatNumber(result);
      _firstNumber = null;
      _pendingOperation = null;
      notifyListeners();
    } catch (e) {
      _display = 'Erreur';
      notifyListeners();
    }
  }

  void clearAll() {
    _display = '0';
    _firstNumber = null;
    _pendingOperation = null;
    notifyListeners();
  }

  String _formatNumber(double num) {
    return num % 1 == 0 ? num.toInt().toString() : num.toStringAsFixed(2);
  }
}
````
## 4) Test unitaire (cas d’erreur)

````dart 
void main() {
  group('CalculatorViewModel', () {
    late CalculatorViewModel viewModel;

    setUp(() {
      viewModel = CalculatorViewModel();
    });

    test('calculateResult with division by zero shows error', () {
      viewModel.inputNumber('10');
      viewModel.setOperation('/');
      viewModel.inputNumber('0');
      
      expect(() => viewModel.calculateResult(), throwsException);
      expect(viewModel.display, 'Erreur');
    });

    test('history is limited to 5 items', () {
      for (int i = 1; i <= 6; i++) {
        viewModel.inputNumber(i.toString());
        viewModel.setOperation('+');
        viewModel.inputNumber('1');
        viewModel.calculateResult();
      }
      
      expect(viewModel.history.length, equals(5));
    });
  });
}
````