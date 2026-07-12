// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/widgets/document_actions_sheet.dart';

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
    DocumentActionsSheet.show(
      context: context,
      pdfPath: widget.pdfPath,
      title: widget.title,
    );
  }
}

