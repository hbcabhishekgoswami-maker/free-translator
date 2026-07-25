import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final storageService = StorageService();
  await storageService.initialize();

  runApp(FreeTranslatorApp(storageService: storageService));
}
