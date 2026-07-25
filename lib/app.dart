import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

class FreeTranslatorApp extends StatelessWidget {
  final StorageService storageService;

  const FreeTranslatorApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Translator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(storageService: storageService),
    );
  }
}
