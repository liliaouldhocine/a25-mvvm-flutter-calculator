import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculatrice_mvvm/viewmodels/settings_viewmodel.dart';

/// Tests unitaires pour SettingsViewModel (Option 3 - Mode Nuit)

/// Ces tests vérifient que le ViewModel gère correctement :
/// 1. L'état initial du mode sombre
/// 2. L'activation/désactivation du mode sombre
/// 3. Le toggle du mode sombre
/// 4. La notification des listeners
/// 5. Le ThemeMode retourné
void main() {
  group('SettingsViewModel', () {
    late SettingsViewModel viewModel;

    // Avant chaque test, créer une nouvelle instance du ViewModel
    setUp(() {
      viewModel = SettingsViewModel();
    });

    test('état initial : isDarkMode devrait être false', () {
      // Arrange & Act : ViewModel créé dans setUp
      // Assert : Vérifier l'état initial
      expect(viewModel.isDarkMode, false);
    });

    test('état initial : themeMode devrait être ThemeMode.light', () {
      // Assert : Vérifier que le ThemeMode correspond à l'état initial
      expect(viewModel.themeMode, ThemeMode.light);
    });

    test('setDarkMode(true) devrait activer le mode sombre', () {
      // Act : Activer le mode sombre
      viewModel.setDarkMode(true);

      // Assert : Vérifier que l'état a changé
      expect(viewModel.isDarkMode, true);
      expect(viewModel.themeMode, ThemeMode.dark);
    });

    test('setDarkMode(false) devrait désactiver le mode sombre', () {
      // Arrange : D'abord activer le mode sombre
      viewModel.setDarkMode(true);

      // Act : Désactiver le mode sombre
      viewModel.setDarkMode(false);

      // Assert : Vérifier que l'état est revenu à false
      expect(viewModel.isDarkMode, false);
      expect(viewModel.themeMode, ThemeMode.light);
    });

    test('toggleDarkMode devrait inverser l\'état du mode sombre', () {
      // État initial : false
      expect(viewModel.isDarkMode, false);

      // Act : Premier toggle
      viewModel.toggleDarkMode();

      // Assert : Devrait être true
      expect(viewModel.isDarkMode, true);

      // Act : Deuxième toggle
      viewModel.toggleDarkMode();

      // Assert : Devrait être false à nouveau
      expect(viewModel.isDarkMode, false);
    });

    test('setDarkMode devrait appeler notifyListeners', () {
      // Arrange : Compteur pour suivre les notifications
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      // Act : Changer l'état
      viewModel.setDarkMode(true);

      // Assert : Le listener devrait avoir été notifié
      expect(notifyCount, 1);
    });

    test('toggleDarkMode devrait appeler notifyListeners', () {
      // Arrange : Compteur pour suivre les notifications
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      // Act : Toggle deux fois
      viewModel.toggleDarkMode();
      viewModel.toggleDarkMode();

      // Assert : Le listener devrait avoir été notifié deux fois
      expect(notifyCount, 2);
    });

    test('themeMode devrait retourner la valeur correcte selon isDarkMode', () {
      // Vérifier la correspondance isDarkMode -> ThemeMode

      // Cas 1 : Mode clair
      viewModel.setDarkMode(false);
      expect(viewModel.themeMode, ThemeMode.light);

      // Cas 2 : Mode sombre
      viewModel.setDarkMode(true);
      expect(viewModel.themeMode, ThemeMode.dark);
    });
  });
}
