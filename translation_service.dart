import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../utils/languages.dart';

class TranslationService {
  OnDeviceTranslator? _translator;
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();
  String? currentSource;
  String? currentTarget;

  Future<void> initialize(String sourceLang, String targetLang) async {
    if (currentSource == sourceLang && currentTarget == targetLang && _translator != null) {
      return;
    }

    final sourceLanguage = SupportedLanguages.getMlKitLanguage(sourceLang);
    final targetLanguage = SupportedLanguages.getMlKitLanguage(targetLang);

    if (sourceLanguage == null || targetLanguage == null) {
      throw Exception('Language not supported for offline translation');
    }

    _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    currentSource = sourceLang;
    currentTarget = targetLang;

    try {
      final srcDownloaded = await _modelManager.isModelDownloaded(sourceLanguage.bcpCode);
      if (!srcDownloaded) {
        await _modelManager.downloadModel(sourceLanguage.bcpCode);
      }
      final tgtDownloaded = await _modelManager.isModelDownloaded(targetLanguage.bcpCode);
      if (!tgtDownloaded) {
        await _modelManager.downloadModel(targetLanguage.bcpCode);
      }
    } catch (e) {
      print('Model download check: $e');
    }
  }

  Future<String> translate(String text) async {
    if (_translator == null) {
      throw Exception('Translator not initialized');
    }
    if (text.trim().isEmpty) return '';

    final result = await _translator!.translateText(text);
    return result;
  }

  void close() {
    _translator?.close();
    _translator = null;
  }
}
