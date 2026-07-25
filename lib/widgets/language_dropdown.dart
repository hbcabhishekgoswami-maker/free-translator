import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/languages.dart';
import '../models/language_model.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedCode;
  final String label;
  final ValueChanged<String> onChanged;

  const LanguageDropdown({
    super.key,
    required this.selectedCode,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final languages = SupportedLanguages.getAvailableLanguages();
    final selectedName = SupportedLanguages.getLanguageName(selectedCode);

    return GestureDetector(
      onTap: () {
        _showLanguagePicker(context, languages);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  selectedName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, List<AppLanguage> languages) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
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
                  'Select $label',
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
                      final isSelected = lang.code == selectedCode;
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
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          lang.nativeName,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.primaryColor)
                            : null,
                        onTap: () {
                          onChanged(lang.code);
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
}
