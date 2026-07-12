// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/scanned_document.dart';
import '../../../../core/utils/document_actions.dart';

class DocumentCard extends StatelessWidget {
  final ScannedDocument document;
  final VoidCallback onTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMd(locale.languageCode);
    final isAr = locale.languageCode == 'ar';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.picture_as_pdf,
                      color: cs.primary, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          dateFormat.format(document.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAr
                                ? '${document.pageCount} صفحة'
                                : '${document.pageCount} p.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert,
                    color: cs.onSurfaceVariant),
                onPressed: () => _showActionSheet(context, isAr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, bool isAr) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(isAr ? 'مشاركة' : 'Share'),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.shareFile(document.pdfPath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: Text(isAr ? 'حفظ في' : 'Save to Files'),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.saveToFiles(
                    context, document.pdfPath,
                    '${document.name}.pdf',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: Text(isAr ? 'طباعة' : 'Print'),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.printPdf(document.pdfPath);
                },
              ),
              if (document.ocrText != null && document.ocrText!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.text_snippet),
                  title: Text(isAr ? 'نسخ النص' : 'Copy text'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _copyText(context, isAr);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyText(BuildContext context, bool isAr) {
    final text = document.ocrText ?? '';
    if (text.isNotEmpty) {
      try {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تم نسخ النص' : 'Text copied'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (_) {}
    }
  }
}

