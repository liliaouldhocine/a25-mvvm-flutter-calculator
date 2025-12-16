import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

/// SettingsScreen
/// - Vue pure: affiche des contrôles liés aux paramètres.
/// - Ne contient pas de logique métier: délègue au SettingsViewModel via Provider.
/// - Respecte MVVM: utilise Consumer/Provider pour lire les états et déclencher des actions.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activez pour utiliser le thème nuit'),
                value: settings.isDarkMode,
                onChanged: settings.toggleDarkMode,
              ),
            ],
          );
        },
      ),
    );
  }
}
