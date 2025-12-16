import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculatorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculatrice MVVM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Affichage
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      viewModel.display,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Clavier
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _buildKeyboard(context, viewModel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKeyboard(
      BuildContext context, CalculatorViewModel viewModel) {
    const List<List<Map<String, dynamic>>> buttonLayout = [
      [
        {'text': 'C', 'color': Colors.red, 'action': 'clear'},
        {'text': '⌫', 'color': Colors.orange, 'action': 'delete'},
        {'text': '÷', 'color': Colors.blue, 'action': 'operation'},
        {'text': '×', 'color': Colors.blue, 'action': 'operation'},
      ],
      [
        {'text': '7', 'color': Colors.grey, 'action': 'number'},
        {'text': '8', 'color': Colors.grey, 'action': 'number'},
        {'text': '9', 'color': Colors.grey, 'action': 'number'},
        {'text': '-', 'color': Colors.blue, 'action': 'operation'},
      ],
      [
        {'text': '4', 'color': Colors.grey, 'action': 'number'},
        {'text': '5', 'color': Colors.grey, 'action': 'number'},
        {'text': '6', 'color': Colors.grey, 'action': 'number'},
        {'text': '+', 'color': Colors.blue, 'action': 'operation'},
      ],
      [
        {'text': '1', 'color': Colors.grey, 'action': 'number'},
        {'text': '2', 'color': Colors.grey, 'action': 'number'},
        {'text': '3', 'color': Colors.grey, 'action': 'number'},
        {'text': '=', 'color': Colors.green, 'action': 'equals', 'flex': 1},
      ],
      [
        {'text': '0', 'color': Colors.grey, 'action': 'number', 'flex': 2},
        {'text': '.', 'color': Colors.grey, 'action': 'decimal'},
        {'text': '%', 'color': Colors.purple, 'action': 'percentage'},
      ],
    ];

    // juste au dessu a la ligne 102 pour le bouton %
    // ===================

    return buttonLayout.map((row) {
      return Expanded(
        child: Row(
          children: row.map((button) {
            final flex = button['flex'] ?? 1;

            return Expanded(
              flex: flex,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => _handleButtonPress(button, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: button['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    button['text'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }


// ================================== ajout d'un case pour le % et apeller notre fonction calculatePercentage()

  void _handleButtonPress(
      Map<String, dynamic> button, CalculatorViewModel viewModel) {
    final text = button['text'];
    final action = button['action'];

    switch (action) {
      case 'number':
        viewModel.inputNumber(text);
        break;
      case 'operation':
        viewModel.setOperation(text);
        break;
      case 'equals':
        viewModel.calculateResult();
        break;
      case 'clear':
        viewModel.clear();
        break;
      case 'delete':
        viewModel.deleteLast();
        break;
      case 'decimal':
        viewModel.inputDecimal();
        break;
      case 'percentage':
        viewModel.calculatePercentage();
        break;
    }
  }
}
