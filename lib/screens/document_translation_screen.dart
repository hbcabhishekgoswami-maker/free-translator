import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../widgets/language_dropdown.dart';
import '../models/translation_history.dart';

class DocumentTranslationScreen extends StatefulWidget {
  final StorageService storageService;

  const DocumentTranslationScreen({super.key, required this.storageService});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TranslationService _translationService = TranslationService();
  String _sourceLang = 'en';
  String _targetLang = 'hi';
  String _originalText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  String? _fileName;

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _isProcessing = true;
        });

        final file = File(result.files.single.path!);
        String content = await file.readAsString();

        setState(() => _originalText = content);

        if (content.trim().isNotEmpty) {
          await _translationService.initialize(_sourceLang, _targetLang);
          final translated = await _translationService.translate(content);
          setState(() => _translatedText = translated);

          await widget.storageService.addHistory(TranslationHistory(
            originalText: content.substring(0, content.length > 500 ? 500 : content.length),
            translatedText: translated.substring(0, translated.length > 500 ? 500 : translated.length),
            sourceLang: _sourceLang,
            targetLang: _targetLang,
            timestamp: DateTime.now(),
            type: 'document',
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Translation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LanguageDropdown(
                    selectedCode: _sourceLang,
                    label: 'FROM',
                    onChanged: (code) => setState(() => _sourceLang = code),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    final temp = _sourceLang;
                    setState(() {
                      _sourceLang = _targetLang;
                      _targetLang = temp;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LanguageDropdown(
                    selectedCode: _targetLang,
                    label: 'TO',
                    onChanged: (code) => setState(() => _targetLang = code),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 56,
                      color: AppTheme.primaryColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pick a Document',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Supports: TXT, PDF, DOC, DOCX',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: AppTheme.accentGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _fileName!,
                        style: const TextStyle(color: AppTheme.accentGreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 12),
              const Text('Translating document...',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
            if (_translatedText.isNotEmpty && !_isProcessing) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRANSLATION',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _actionButton(
                          icon: Icons.copy,
                          label: 'Copy',
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _translatedText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied!'),
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _translationService.close();
    super.dispose();
  }
}
