// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scanner/domain/entities/scanned_document.dart';
import '../../../scanner/presentation/providers/scanner_providers.dart';
import 'images_to_pdf_screen.dart';
import 'merge_pdf_screen.dart';
import 'compress_pdf_screen.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final docs = ref.watch(scannerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الأدوات' : 'Tools'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'ماذا تريد أن تفعل؟' : 'What would you like to do?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _ToolCard(
                    icon: Icons.collections_bookmark,
                    label: isAr ? 'صور إلى PDF' : 'Images to PDF',
                    desc: isAr
                        ? 'اختيار صور متعددة وتحويلها إلى PDF'
                        : 'Pick multiple images & convert to PDF',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImagesToPdfScreen()),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.merge,
                    label: isAr ? 'دمج PDF' : 'Merge PDF',
                    desc: isAr
                        ? 'دمج مستندين أو أكثر في ملف واحد'
                        : 'Combine multiple documents into one',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MergePdfScreen()),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.compress,
                    label: isAr ? 'ضغط PDF' : 'Compress PDF',
                    desc: isAr
                        ? 'تقليل حجم ملف PDF للجودة المنخفضة'
                        : 'Reduce PDF file size for lower quality',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompressPdfScreen()),
                    ),
                  ),
                  _ToolCard(
                    icon: Icons.text_snippet,
                    label: isAr ? 'استخراج النص' : 'Extract Text',
                    desc: isAr
                        ? 'نسخ النص من المستند'
                        : 'Copy text from document',
                    onTap: () => _pickDocForText(context, ref, isAr, docs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDocForText(BuildContext context, WidgetRef ref, bool isAr,
      AsyncValue<List<ScannedDocument>> docs) {
    docs.whenData((list) {
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(isAr ? 'لا توجد مستندات' : 'No documents found')),
        );
        return;
      }
      _showDocPicker(context, isAr, list);
    });
  }

  void _showDocPicker(
      BuildContext context, bool isAr, List<ScannedDocument> docs) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isAr ? 'اختر مستنداً' : 'Select a document',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final hasText = doc.ocrText != null &&
                      doc.ocrText!.isNotEmpty;
                  return ListTile(
                    leading: Icon(
                      hasText ? Icons.text_snippet : Icons.description,
                      color: hasText ? null : Colors.grey,
                    ),
                    title: Text(doc.name),
                    subtitle: Text(
                      hasText
                          ? isAr
                              ? '${doc.ocrText!.split(' ').length} كلمة'
                              : '${doc.ocrText!.split(' ').length} words'
                          : isAr
                              ? 'لا يوجد نص'
                              : 'No text',
                    ),
                    enabled: hasText,
                    onTap: hasText
                        ? () {
                            Navigator.pop(ctx);
                            _showText(context, isAr, doc);
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showText(BuildContext context, bool isAr, ScannedDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc.name),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(doc.ocrText ?? ''),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc,
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
