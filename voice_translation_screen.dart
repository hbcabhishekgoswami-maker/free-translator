import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';

import '../widgets/language_dropdown.dart';
import '../models/translation_history.dart';

class VoiceTranslationScreen extends StatefulWidget {
  final StorageService storageService;

  const VoiceTranslationScreen({super.key, required this.storageService});

  @override
  State<VoiceTranslationScreen> createState() => _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends State<VoiceTranslationScreen>
    with SingleTickerProviderStateMixin {
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();
  String _sourceLang = 'en';
  String _targetLang = 'hi';
  bool _isListening = false;
  bool _isTranslating = false;
  String _spokenText = '';
  String _translatedText = '';
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _speechService.initialize();
    try {
      await _translationService.initialize(_sourceLang, _targetLang);
    } catch (e) {
      print('Translation init error: $e');
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      _animController.stop();
      if (_spokenText.isNotEmpty) {
        await _translateSpokenText();
      }
    } else {
      setState(() {
        _isListening = true;
        _spokenText = '';
        _translatedText = '';
      });
      _animController.repeat(reverse: true);

      final localeId = _speechService.getLocaleId(_sourceLang);
      await _speechService.startListening(
        onResult: (text) {
          setState(() => _spokenText = text);
        },
        localeId: localeId,
      );
    }
  }

  Future<void> _translateSpokenText() async {
    if (_spokenText.trim().isEmpty) return;

    setState(() => _isTranslating = true);
    try {
      await _translationService.initialize(_sourceLang, _targetLang);
      final result = await _translationService.translate(_spokenText);
      setState(() => _translatedText = result);

      final targetLocale = _speechService.getLocaleId(_targetLang);
      await _speechService.speak(result, localeId: targetLocale);

      await widget.storageService.addHistory(TranslationHistory(
        originalText: _spokenText,
        translatedText: result,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        timestamp: DateTime.now(),
        type: 'voice',
      ));
    } catch (e) {
      print('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      final tempText = _spokenText;
      _spokenText = _translatedText;
      _translatedText = tempText;
    });
    _initializeServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Translation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LanguageDropdown(
                    selectedCode: _sourceLang,
                    label: 'SPEAKING',
                    onChanged: (code) {
                      setState(() => _sourceLang = code);
                      _initializeServices();
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
                    label: 'TRANSLATING TO',
                    onChanged: (code) {
                      setState(() => _targetLang = code);
                      _initializeServices();
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    _spokenText.isEmpty
                        ? 'Tap the mic and start speaking...'
                        : _spokenText,
                    style: TextStyle(
                      color: _spokenText.isEmpty
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontSize: 18,
                      fontStyle: _spokenText.isEmpty ? FontStyle.normal : FontStyle.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (_isTranslating)
                    const CircularProgressIndicator(color: AppTheme.accentBlue)
                  else
                    Text(
                      _translatedText.isEmpty
                          ? 'Translation will appear here...'
                          : _translatedText,
                      style: TextStyle(
                        color: _translatedText.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.accentBlue,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_translatedText.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final targetLocale = _speechService.getLocaleId(_targetLang);
                      _speechService.speak(_translatedText, localeId: targetLocale);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: AppTheme.accentBlue,
                        size: 28,
                      ),
                    ),
                  ),
                const SizedBox(width: 24),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isListening ? _pulseAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppTheme.secondaryColor
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? AppTheme.secondaryColor
                                    : AppTheme.primaryColor)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                if (_spokenText.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _spokenText = '';
                        _translatedText = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: AppTheme.textSecondary,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _translationService.close();
    _speechService.dispose();
    _animController.dispose();
    super.dispose();
  }
}
