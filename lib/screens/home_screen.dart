import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../models/translation_history.dart';
import '../utils/languages.dart';
import '../widgets/feature_card.dart';
import 'text_translation_screen.dart';
import 'voice_translation_screen.dart';
import 'camera_translation_screen.dart';
import 'document_translation_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  static const MethodChannel _overlayChannel = MethodChannel('com.hitranslate/overlay');
  final TextEditingController _quickTranslateController = TextEditingController();
  final TextEditingController _quickTranslateOutput = TextEditingController();
  final TranslationService _quickTranslationService = TranslationService();
  String _quickSourceLang = 'en';
  String _quickTargetLang = 'hi';
  bool _isOverlayActive = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();
  }

  Future<void> _startFloatingTranslator() async {
    try {
      final hasPermission = await _overlayChannel.invokeMethod('canDrawOverlay');
      if (!hasPermission) {
        await _overlayChannel.invokeMethod('requestOverlayPermission');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please grant overlay permission, then try again'),
              backgroundColor: AppTheme.accentOrange,
            ),
          );
        }
        return;
      }

      if (_quickTranslateController.text.isEmpty) {
        await _overlayChannel.invokeMethod('startOverlayService', {
          'text': 'Floating translator active! Type or paste text to translate.',
          'sourceLang': _quickSourceLang,
          'targetLang': _quickTargetLang,
        });
      } else {
        await _quickTranslationService.initialize(_quickSourceLang, _quickTargetLang);
        final translated = await _quickTranslationService.translate(_quickTranslateController.text);
        await _overlayChannel.invokeMethod('startOverlayService', {
          'text': '${_quickTranslateController.text}\n\n$translated',
          'sourceLang': _quickSourceLang,
          'targetLang': _quickTargetLang,
        });
      }

      setState(() => _isOverlayActive = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Overlay error: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }

  Future<void> _stopFloatingTranslator() async {
    try {
      await _overlayChannel.invokeMethod('stopOverlayService');
      setState(() => _isOverlayActive = false);
    } catch (e) {
      print('Stop overlay error: $e');
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      HistoryScreen(storageService: widget.storageService),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceBg, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomNavItem(Icons.home_rounded, 'Home', 0),
                _bottomNavItem(Icons.history_rounded, 'History', 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: 22),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.translate, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Translator',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '100% Free • Offline • Private',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showQuickLangPicker(true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FROM',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              Text(
                                SupportedLanguages.getLanguageName(_quickSourceLang),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final temp = _quickSourceLang;
                          setState(() {
                            _quickSourceLang = _quickTargetLang;
                            _quickTargetLang = temp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.swap_horiz,
                              color: AppTheme.primaryColor, size: 20),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showQuickLangPicker(false),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('TO',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              Text(
                                SupportedLanguages.getLanguageName(_quickTargetLang),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _quickTranslateController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Quick translate...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_quickTranslateOutput.text.isNotEmpty) ...[
                    const Divider(color: AppTheme.surfaceBg, height: 20),
                    Text(
                      _quickTranslateOutput.text,
                      style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_quickTranslateController.text.isEmpty) return;
                            try {
                              await _quickTranslationService.initialize(
                                  _quickSourceLang, _quickTargetLang);
                              final result = await _quickTranslationService
                                  .translate(_quickTranslateController.text);
                              setState(() => _quickTranslateOutput.text = result);
                              await widget.storageService.addHistory(
                                  TranslationHistory(
                                originalText: _quickTranslateController.text,
                                translatedText: result,
                                sourceLang: _quickSourceLang,
                                targetLang: _quickTargetLang,
                                timestamp: DateTime.now(),
                                type: 'text',
                              ));
                            } catch (e) {
                              print('Quick translate error: $e');
                            }
                          },
                          child: const Text('Translate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _isOverlayActive ? _stopFloatingTranslator : _startFloatingTranslator,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOverlayActive
                        ? [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.7)]
                        : [AppTheme.accentGreen, AppTheme.accentGreen.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isOverlayActive ? AppTheme.secondaryColor : AppTheme.accentGreen)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOverlayActive ? Icons.stop_circle : Icons.open_in_new,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isOverlayActive ? 'Stop Floating Translator' : 'Start Floating Translator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Translation Tools',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                FeatureCard(
                  icon: Icons.text_fields,
                  title: 'Text',
                  subtitle: 'Type or paste text',
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateTo(
                    TextTranslationScreen(storageService: widget.storageService),
                  ),
                ),
                FeatureCard(
                  icon: Icons.mic,
                  title: 'Voice',
                  subtitle: 'Speak to translate',
                  color: AppTheme.secondaryColor,
                  onTap: () => _navigateTo(
                    VoiceTranslationScreen(storageService: widget.storageService),
                  ),
                ),
                FeatureCard(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  subtitle: 'Scan & translate text',
                  color: AppTheme.accentOrange,
                  onTap: () => _navigateTo(
                    CameraTranslationScreen(storageService: widget.storageService),
                  ),
                ),
                FeatureCard(
                  icon: Icons.description,
                  title: 'Document',
                  subtitle: 'Translate files',
                  color: AppTheme.accentBlue,
                  onTap: () => _navigateTo(
                    DocumentTranslationScreen(storageService: widget.storageService),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shield, color: AppTheme.accentGreen, size: 32),
                  SizedBox(height: 8),
                  Text(
                    '100% Private & Secure',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All translations happen on your device.\nNo data is sent to any server.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showQuickLangPicker(bool isSource) {
    final languages = SupportedLanguages.getAvailableLanguages();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSource ? 'Source Language' : 'Target Language',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final currentLang = isSource ? _quickSourceLang : _quickTargetLang;
                      final isSelected = lang.code == currentLang;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.2)
                                : AppTheme.surfaceBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              lang.code.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(lang.nativeName,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            if (isSource) {
                              _quickSourceLang = lang.code;
                            } else {
                              _quickTargetLang = lang.code;
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _quickTranslateController.dispose();
    _quickTranslateOutput.dispose();
    _quickTranslationService.close();
    super.dispose();
  }
}
