import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../services/ocr_service.dart';
import '../services/storage_service.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/translation_text_field.dart';
import '../models/translation_history.dart';

class CameraTranslationScreen extends StatefulWidget {
  final StorageService storageService;

  const CameraTranslationScreen({super.key, required this.storageService});

  @override
  State<CameraTranslationScreen> createState() => _CameraTranslationScreenState();
}

class _CameraTranslationScreenState extends State<CameraTranslationScreen> {
  final TranslationService _translationService = TranslationService();
  final OcrService _ocrService = OcrService();
  final ImagePicker _imagePicker = ImagePicker();
  String _sourceLang = 'en';
  String _targetLang = 'hi';
  String _extractedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isProcessing = true;
        });
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }

  Future<void> _processImage(String filePath) async {
    setState(() => _isProcessing = true);

    try {
      final extractedText = await _ocrService.recognizeTextFromFile(filePath);
      setState(() => _extractedText = extractedText);

      if (extractedText.trim().isNotEmpty) {
        await _translationService.initialize(_sourceLang, _targetLang);
        final translated = await _translationService.translate(extractedText);
        setState(() => _translatedText = translated);

        await widget.storageService.addHistory(TranslationHistory(
          originalText: extractedText,
          translatedText: translated,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          timestamp: DateTime.now(),
          type: 'camera',
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
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
        title: const Text('Photo Translation'),
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
                    child: const Icon(
                      Icons.swap_horiz,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
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
            const SizedBox(height: 20),
            if (_imageFile == null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Take a photo or pick from gallery',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _pickImageButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: 20),
                        _pickImageButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageFile = null;
                            _extractedText = '';
                            _translatedText = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 12),
                    Text('Processing image...',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            if (_extractedText.isNotEmpty && !_isProcessing) ...[
              const SizedBox(height: 16),
              TranslationTextField(
                controller: TextEditingController(text: _extractedText),
                label: 'EXTRACTED TEXT',
                readOnly: true,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TranslationTextField(
                controller: TextEditingController(text: _translatedText),
                label: 'TRANSLATION',
                readOnly: true,
                maxLines: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pickImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
    _ocrService.close();
    super.dispose();
  }
}
