// lib/main.dart
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
    return ChangeNotifierProvider(
      create: (context) => CalculatorViewModel(),
      child: MaterialApp(
        title: 'Calculatrice MVVM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const CalculatorScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
