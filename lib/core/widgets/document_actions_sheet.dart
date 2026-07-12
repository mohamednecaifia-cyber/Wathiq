// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/document_actions.dart';

class DocumentActionsSheet {
  static void show({
    required BuildContext context,
    required String pdfPath,
    required String title,
    String? ocrText,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(
                icon: Icons.share,
                label: isAr ? 'مشاركة' : 'Share',
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.shareFile(pdfPath);
                },
              ),
              _ActionTile(
                icon: Icons.save_alt,
                label: isAr ? 'حفظ في' : 'Save to Files',
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.saveToFiles(context, pdfPath,
                      title.endsWith('.pdf') ? title : '$title.pdf');
                },
              ),
              _ActionTile(
                icon: Icons.print,
                label: isAr ? 'طباعة' : 'Print',
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.printPdf(pdfPath);
                },
              ),
              if (ocrText != null && ocrText.isNotEmpty)
                _ActionTile(
                  icon: Icons.text_snippet,
                  label: isAr ? 'نسخ النص' : 'Copy text',
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: ocrText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(isAr ? 'تم نسخ النص' : 'Text copied'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
