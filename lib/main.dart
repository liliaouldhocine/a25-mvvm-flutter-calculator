import 'package:flutter/material.dart';
import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';
import 'package:calculatrice_mvvm/views/calculator_screen.dart';
import 'package:calculatrice_mvvm/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Calculatrice MVVM',
            // Thème clair
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            // Thème sombre
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.dark),
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            // Piloté par SettingsViewModel
            themeMode: settings.themeMode,
            home: const CalculatorScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
