// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_reminder_app/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  // <<< PASTIKAN INI TERDEFINISI SEPERTI INI
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Theme', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            RadioListTile<AppThemeColor>(
              title: const Text('Teal (Green-ish Blue)'),
              value: AppThemeColor.teal,
              groupValue: themeProvider.currentThemeColor,
              onChanged: (AppThemeColor? value) {
                if (value != null) {
                  themeProvider.setThemeColor(value);
                }
              },
            ),
            RadioListTile<AppThemeColor>(
              title: const Text('Blue'),
              value: AppThemeColor.blue,
              groupValue: themeProvider.currentThemeColor,
              onChanged: (AppThemeColor? value) {
                if (value != null) {
                  themeProvider.setThemeColor(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
