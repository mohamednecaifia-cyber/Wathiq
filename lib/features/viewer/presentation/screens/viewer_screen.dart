// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/utils/document_actions.dart';

class ViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const ViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  Uint8List? _cachedBytes;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    try {
      final bytes = await File(widget.pdfPath).readAsBytes();
      if (mounted) setState(() => _cachedBytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionSheet(context),
          ),
        ],
      ),
      body: _cachedBytes != null
          ? PdfPreview(
              pdfFileName: widget.title,
              build: (format) => _cachedBytes!,
              canChangeOrientation: true,
              canDebug: false,
              actions: const [],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _showActionSheet(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
                  DocumentActions.shareFile(widget.pdfPath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: Text(isAr ? 'حفظ في' : 'Save to Files'),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.saveToFiles(
                    context, widget.pdfPath,
                    widget.title.endsWith('.pdf') ? widget.title : '${widget.title}.pdf',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: Text(isAr ? 'طباعة' : 'Print'),
                onTap: () {
                  Navigator.pop(ctx);
                  DocumentActions.printPdf(widget.pdfPath);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

