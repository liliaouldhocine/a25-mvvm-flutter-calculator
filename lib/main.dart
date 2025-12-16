import 'package:flutter/material.dart';
import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';
import 'package:calculatrice_mvvm/viewmodels/settings_viewmodel.dart';
import 'package:calculatrice_mvvm/views/calculator_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de MultiProvider pour gérer plusieurs ViewModels
    // Respecte l'architecture MVVM en gardant les ViewModels séparés
    // selon leurs responsabilités : calculs VS paramètres
    return MultiProvider(
      providers: [
        // CalculatorViewModel pour la logique de calcul (existant)
        ChangeNotifierProvider(
          create: (context) => CalculatorViewModel(),
        ),
        // SettingsViewModel pour la gestion des paramètres et du thème (nouveau)
        ChangeNotifierProvider(
          create: (context) => SettingsViewModel(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        // Consumer permet de reconstruire MaterialApp quand le thème change
        // Optimisation : seul MaterialApp est reconstruit, pas toute l'application
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Calculatrice MVVM',
            // Thème dynamique géré par le SettingsViewModel
            // Respecte le principe de responsabilité unique : le ViewModel gère le thème
            theme: settingsViewModel.currentTheme,
            home: const CalculatorScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
