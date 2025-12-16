import 'package:flutter/material.dart';
import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';
import 'package:calculatrice_mvvm/viewmodels/settings_viewmodel.dart';
import 'package:calculatrice_mvvm/views/calculator_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

/// MyApp - Widget racine de l'application
///
/// Architecture MVVM - Gestion du thème dynamique (Option 3) mode nuit :
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider : Permet d'injecter plusieurs providers/ViewModels
    return MultiProvider(
      providers: [
        // ViewModel pour les calculs (existant)
        ChangeNotifierProvider(create: (context) => CalculatorViewModel()),
        // ViewModel pour les paramètres/thème (nouveau - Option 3)
        ChangeNotifierProvider(create: (context) => SettingsViewModel()),
      ],
      // Consumer : Reconstruit MaterialApp quand le thème change
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Calculatrice MVVM',
            // Thème clair : Utilisé quand isDarkMode = false
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            // Thème sombre : Utilisé quand isDarkMode = true
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
              // Couleur de fond plus sombre pour le mode nuit
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            // themeMode : Déterminé par le SettingsViewModel
            themeMode: settingsViewModel.themeMode,
            home: const CalculatorScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
