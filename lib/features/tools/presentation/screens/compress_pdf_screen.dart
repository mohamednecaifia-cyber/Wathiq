// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../../scanner/domain/entities/scanned_document.dart';
import '../../../scanner/presentation/providers/scanner_providers.dart';
import '../../../viewer/presentation/screens/viewer_screen.dart';

class CompressPdfScreen extends ConsumerStatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  ConsumerState<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends ConsumerState<CompressPdfScreen> {
  ScannedDocument? _selected;
  double _quality = 0.5;
  bool _isCompressing = false;

  static const _qualityPresets = {
    'عالية': 0.75,
    'متوسطة': 0.5,
    'مضغوطة': 0.25,
  };

  Future<void> _compress() async {
    if (_selected == null) return;
    setState(() => _isCompressing = true);
    try {
      final images = _selected!.sourceImagePaths!;
      final maxDim = (_quality * 2000).round().clamp(400, 2000);
      final jpegQuality = (_quality * 85).round().clamp(20, 85);

      final compressed = <String>[];
      final baseDir = await Directory.systemTemp.createTemp('compress_');

      for (int i = 0; i < images.length; i++) {
        final bytes = await ImageEnhancer.compress(images[i],
            maxDimension: maxDim, quality: jpegQuality);
        final path = '${baseDir.path}/page_${i.toString().padLeft(4, '0')}.jpg';
        await File(path).writeAsBytes(bytes);
        compressed.add(path);
      }

      final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFile = await FileUtils.createPdfFromImages(
        imagePaths: compressed,
        fileName: fileName,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(pdfPath: pdfFile.path, title: 'ملف مضغوط'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الضغط: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompressing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(scannerNotifierProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'ضغط PDF' : 'Compress PDF'),
        centerTitle: true,
      ),
      body: docs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final eligible = list.where((d) =>
              d.sourceImagePaths != null && d.sourceImagePaths!.isNotEmpty).toList();
          if (eligible.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.compress, size: 80, color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text(isAr ? 'لا توجد مستندات تحتوي على صور مصدر' : 'No documents with source images',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'سيتم حفظ صور المصدر تلقائياً عند المسح القادم'
                          : 'Source images will be saved automatically on next scan',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(isAr ? 'اختر مستنداً' : 'Select a document',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButton<ScannedDocument>(
                value: _selected,
                isExpanded: true,
                hint: Text(isAr ? 'اختر مستنداً...' : 'Choose a document...'),
                items: eligible.map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _selected = v),
              ),
              if (_selected != null) ...[
                const SizedBox(height: 24),
                Text(isAr ? 'مستوى الضغط' : 'Compression level',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(isAr ? 'أقل' : 'Less', style: theme.textTheme.bodySmall),
                    Expanded(
                      child: Slider(
                        value: _quality,
                        onChanged: (v) => setState(() => _quality = v),
                        divisions: 3,
                        min: 0.25,
                        max: 1.0,
                      ),
                    ),
                    Text(isAr ? 'أكثر' : 'More', style: theme.textTheme.bodySmall),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _qualityPresets.entries.map((e) {
                    final active = (_quality * 100).round() == (e.value * 100).round();
                    return ChoiceChip(
                      label: Text(isAr ? e.key : e.key),
                      selected: active,
                      onSelected: (v) {
                        if (v) setState(() => _quality = e.value);
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selected != null && !_isCompressing ? _compress : null,
                  icon: _isCompressing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.compress),
                  label: Text(
                    _isCompressing
                        ? (isAr ? 'جاري الضغط...' : 'Compressing...')
                        : (isAr ? 'ضغط' : 'Compress'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

