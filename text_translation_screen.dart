import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/translation_text_field.dart';
import '../models/translation_history.dart';

class TextTranslationScreen extends StatefulWidget {
  final StorageService storageService;

  const TextTranslationScreen({super.key, required this.storageService});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  String _sourceLang = 'en';
  String _targetLang = 'hi';
  bool _isTranslating = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTranslator();
  }

  Future<void> _initializeTranslator() async {
    try {
      await _translationService.initialize(_sourceLang, _targetLang);
      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation model download needed. Please wait...'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
    }
  }

  Future<void> _translate() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      if (!_isInitialized || _sourceLang != _translationService.currentSource || _targetLang != _translationService.currentTarget) {
        await _translationService.initialize(_sourceLang, _targetLang);
        setState(() => _isInitialized = true);
      }

      final result = await _translationService.translate(_inputController.text);
      setState(() => _outputController.text = result);

      await widget.storageService.addHistory(TranslationHistory(
        originalText: _inputController.text,
        translatedText: result,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        timestamp: DateTime.now(),
        type: 'text',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }

    setState(() => _isTranslating = false);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      final tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
    _initializeTranslator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Translation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _inputController.clear();
              _outputController.clear();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LanguageDropdown(
                    selectedCode: _sourceLang,
                    label: 'FROM',
                    onChanged: (code) {
                      setState(() => _sourceLang = code);
                      _initializeTranslator();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LanguageDropdown(
                    selectedCode: _targetLang,
                    label: 'TO',
                    onChanged: (code) {
                      setState(() => _targetLang = code);
                      _initializeTranslator();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TranslationTextField(
                      controller: _inputController,
                      label: 'SOURCE TEXT',
                      hintText: 'Type or paste text here...',
                      maxLines: 6,
                      onClear: () {
                        _inputController.clear();
                        _outputController.clear();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isTranslating ? null : _translate,
                        icon: _isTranslating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.translate, size: 20),
                        label: Text(_isTranslating ? 'Translating...' : 'Translate'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TranslationTextField(
                      controller: _outputController,
                      label: 'TRANSLATION',
                      readOnly: true,
                      maxLines: 6,
                      hintText: 'Translation will appear here...',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _translationService.close();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
