import 'package:calculatrice_mvvm/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:calculatrice_mvvm/viewmodels/calculator_viewmodel.dart';
import 'package:calculatrice_mvvm/views/calculator_screen.dart';
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
            debugShowCheckedModeBanner: false,

            /// Thème clair
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),

            /// Thème sombre
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
            ),

            themeMode:
                settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}