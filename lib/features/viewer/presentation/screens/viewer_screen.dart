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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    try {
      final file = File(widget.pdfPath);
      if (!await file.exists()) {
        if (mounted) setState(() => _error = 'File not found: ${widget.pdfPath}');
        return;
      }
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _cachedBytes = bytes);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load PDF: $e');
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (_cachedBytes != null) {
      return PdfPreview(
        pdfFileName: widget.title,
        build: (format) => _cachedBytes!,
        canChangeOrientation: true,
        canDebug: false,
        actions: const [],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  void _showActionSheet(BuildContext context) {
    DocumentActionsSheet.show(
      context: context,
      pdfPath: widget.pdfPath,
      title: widget.title,
    );
  }
}

