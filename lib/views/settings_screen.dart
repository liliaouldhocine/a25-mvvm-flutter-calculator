import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

/// Écran des paramètres de l'application
/// Respecte l'architecture MVVM : cette View ne contient aucune logique métier,
/// elle ne fait que présenter l'interface et transmettre les actions utilisateur au ViewModel
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        // L'icône de retour est automatiquement gérée par Flutter
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Apparence
            const Text(
              'Apparence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Utilisation de Consumer pour écouter les changements du SettingsViewModel
            // Consumer permet de reconstruire uniquement cette partie de l'interface
            // quand le thème change, optimisant les performances
            Consumer<SettingsViewModel>(
              builder: (context, settingsViewModel, child) {
                return Card(
                  child: SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: Text(
                      settingsViewModel.isDarkTheme 
                          ? 'Thème sombre activé' 
                          : 'Thème clair activé'
                    ),
                    value: settingsViewModel.isDarkTheme,
                    
                    // Action transmise au ViewModel quand l'utilisateur interagit
                    // La View ne fait que transmettre l'action, sans logique métier
                    onChanged: (bool value) {
                      settingsViewModel.toggleTheme();
                    },
                    
                    // Icône appropriée selon l'état actuel
                    secondary: Icon(
                      settingsViewModel.isDarkTheme 
                          ? Icons.dark_mode 
                          : Icons.light_mode
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Section d'information
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('Calculatrice MVVM'),
                subtitle: Text('Version 1.0.0\nApplication développée avec Flutter'),
                isThreeLine: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}