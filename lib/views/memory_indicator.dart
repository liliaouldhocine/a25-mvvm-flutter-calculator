import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';

/// Widget qui affiche l'état de la mémoire
/// Ce widget utilise Consumer pour optimiser les reconstructions
class MemoryIndicator extends StatelessWidget {
  const MemoryIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorViewModel>(
      builder: (context, viewModel, child) {
        // Si pas de mémoire, on n'affiche rien
        if (!viewModel.hasMemory) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.memory,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                viewModel.memoryDisplay,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}