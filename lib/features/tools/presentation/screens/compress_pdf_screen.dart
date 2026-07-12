// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/scanned_document.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../../../core/widgets/empty_source_images.dart';
import '../../../../core/widgets/loading_button.dart';
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
    'عالية/High': 0.75,
    'متوسطة/Medium': 0.5,
    'مضغوطة/Low': 0.25,
  };

  Future<void> _compress() async {
    final doc = _selected;
    if (doc == null) return;
    final images = doc.sourceImagePaths;
    if (images == null || images.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد صور مصدر للضغط')),
        );
      }
      return;
    }
    setState(() => _isCompressing = true);
    try {
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
    return;
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
            return const EmptySourceImages(icon: Icons.compress);
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
                      label: Text(e.key.split('/').last),
                      selected: active,
                      onSelected: (v) {
                        if (v) setState(() => _quality = e.value);
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              LoadingButton(
                isLoading: _isCompressing,
                isEnabled: _selected != null,
                onPressed: _compress,
                icon: Icons.compress,
                idleLabel: isAr ? 'ضغط' : 'Compress',
                loadingLabel: isAr ? 'جاري الضغط...' : 'Compressing...',
              ),
            ],
          );
        },
      ),
    );
  }
}

