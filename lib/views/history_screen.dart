// lib/views/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculatorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des calculs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                viewModel.history.isEmpty ? null : viewModel.clearHistory,
          ),
        ],
      ),
      body: viewModel.history.isEmpty
          ? const Center(
              child: Text(
                'Aucun calcul dans l\'historique',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: viewModel.history.length,
              itemBuilder: (context, index) {
                final calculation = viewModel.history.reversed.toList()[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((viewModel.history.length - index).toString()),
                  ),
                  title: Text(
                    calculation.expression,
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    'Résultat: ${calculation.result}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${calculation.timestamp.hour}:${calculation.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
