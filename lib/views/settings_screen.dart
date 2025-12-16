import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

/// SettingsScreen - Écran de paramètres de l'application
///
/// Architecture MVVM :
/// - Cette View est un StatelessWidget car tout l'état est géré par le ViewModel.
/// - Elle utilise Consumer<SettingsViewModel> pour écouter les changements d'état
///   et se reconstruire automatiquement quand notifyListeners() est appelé.
/// - Aucune logique métier n'est présente ici, uniquement de l'affichage
///   et des appels aux méthodes du ViewModel.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      // Consumer : Widget Provider qui écoute les changements du ViewModel
      // et reconstruit uniquement cette partie de l'arbre quand l'état change.
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return ListView(
            children: [
              // Section Apparence
              _buildSectionHeader('Apparence'),

              // Toggle Mode Nuit
              // SwitchListTile offre une expérience utilisateur standard pour les toggles
              SwitchListTile(
                title: const Text('Mode Nuit'),
                subtitle: Text(
                  settingsViewModel.isDarkMode
                      ? 'Thème sombre activé'
                      : 'Thème clair activé',
                ),
                // Icône adaptative selon l'état du mode
                secondary: Icon(
                  settingsViewModel.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: settingsViewModel.isDarkMode
                      ? Colors.amber
                      : Colors.orange,
                ),
                // L'état du switch est lié au getter du ViewModel
                value: settingsViewModel.isDarkMode,
                // Le callback appelle la méthode du ViewModel pour modifier l'état
                // La View ne modifie jamais l'état directement (principe MVVM)
                onChanged: (bool value) {
                  settingsViewModel.setDarkMode(value);
                },
              ),

              const Divider(),

              // Information sur le thème actuel
              const ListTile(
                leading: Icon(Icons.info_outline),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construit un en-tête de section pour organiser les paramètres
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
