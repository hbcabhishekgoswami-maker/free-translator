import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../models/translation_history.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storageService;

  const HistoryScreen({super.key, required this.storageService});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final history = _showFavoritesOnly
        ? widget.storageService.getFavorites()
        : widget.storageService.getAllHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        actions: [
          if (!_showFavoritesOnly && history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.cardBg,
                    title: const Text('Clear History',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text('Delete all translation history?',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await widget.storageService.clearHistory();
                          Navigator.pop(ctx);
                          setState(() {});
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: AppTheme.secondaryColor)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('All', !_showFavoritesOnly, () {
                  setState(() => _showFavoritesOnly = false);
                }),
                const SizedBox(width: 8),
                _filterChip('Favorites', _showFavoritesOnly, () {
                  setState(() => _showFavoritesOnly = true);
                }),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showFavoritesOnly ? Icons.favorite_border : Icons.history,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showFavoritesOnly
                              ? 'No favorites yet'
                              : 'No translation history',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _historyCard(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _historyCard(TranslationHistory item, int index) {
    final typeIcons = {
      'text': Icons.text_fields,
      'voice': Icons.mic,
      'camera': Icons.camera_alt,
      'document': Icons.description,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcons[item.type] ?? Icons.translate,
                  size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text(
                '${item.sourceLang.toUpperCase()} → ${item.targetLang.toUpperCase()}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM, HH:mm').format(item.timestamp),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final allHistory = widget.storageService.getAllHistory();
                  final realIndex = widget.storageService.getAllHistory().indexOf(item);
                  await widget.storageService.toggleFavorite(realIndex);
                  setState(() {});
                },
                child: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: item.isFavorite ? AppTheme.secondaryColor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.originalText,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            item.translatedText,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.translatedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied!'),
                      backgroundColor: AppTheme.accentGreen,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 12, color: AppTheme.textSecondary),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final allHistory = widget.storageService.getAllHistory();
                  final realIndex = allHistory.indexOf(item);
                  await widget.storageService.deleteHistory(realIndex);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 12, color: AppTheme.secondaryColor),
                      SizedBox(width: 4),
                      Text('Delete',
                          style: TextStyle(color: AppTheme.secondaryColor, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
