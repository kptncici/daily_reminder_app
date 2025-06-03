import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'theme/theme.dart'; // Pastikan file ini ada dan terhubung

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi Notifikasi Lokal
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final primaryColor = themeProvider.getPrimaryMaterialColor();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Daily Reminder',
            theme: getThemeData(primaryColor), // Gunakan fungsi dari theme.dart
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
