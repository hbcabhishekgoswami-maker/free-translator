import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class TranslationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final int maxLines;
  final String? hintText;
  final VoidCallback? onClear;
  final Widget? suffixWidget;

  const TranslationTextField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.maxLines = 5,
    this.hintText,
    this.onClear,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: readOnly
              ? AppTheme.accentBlue.withOpacity(0.2)
              : AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: readOnly ? AppTheme.accentBlue : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: readOnly ? AppTheme.accentBlue : AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (controller.text.isNotEmpty && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close,
                        size: 18, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: maxLines,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? (readOnly ? 'Translation will appear here...' : 'Enter text to translate...'),
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _actionButton(
                    icon: Icons.copy,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          backgroundColor: AppTheme.accentGreen,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    icon: Icons.share,
                    onTap: () {
                      Share.share(controller.text);
                    },
                  ),
                  if (suffixWidget != null) ...[
                    const Spacer(),
                    suffixWidget!,
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textSecondary),
      ),
    );
  }
}
