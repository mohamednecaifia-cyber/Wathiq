// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/empty_source_images.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../scanner/presentation/providers/scanner_providers.dart';
import '../../../viewer/presentation/screens/viewer_screen.dart';

class MergePdfScreen extends ConsumerStatefulWidget {
  const MergePdfScreen({super.key});

  @override
  ConsumerState<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends ConsumerState<MergePdfScreen> {
  final Set<String> _selected = {};
  bool _isMerging = false;

  Future<void> _merge() async {
    setState(() => _isMerging = true);
    try {
      final docs = ref.read(scannerNotifierProvider).valueOrNull ?? [];
      final selectedDocs = docs.where((d) => _selected.contains(d.id)).toList();

      final allImages = <String>[];
      for (final doc in selectedDocs) {
        if (doc.sourceImagePaths != null) {
          allImages.addAll(doc.sourceImagePaths!);
        }
      }

      if (allImages.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على صور المصدر')),
          );
        }
        return;
      }

      final fileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFile = await FileUtils.createPdfFromImages(
        imagePaths: allImages,
        fileName: fileName,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(pdfPath: pdfFile.path, title: 'ملف مدمج'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الدمج: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isMerging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(scannerNotifierProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'دمج PDF' : 'Merge PDF'),
        centerTitle: true,
      ),
      body: docs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final eligible = list.where((d) =>
              d.sourceImagePaths != null && d.sourceImagePaths!.isNotEmpty).toList();
          if (eligible.isEmpty) {
            return const EmptySourceImages(icon: Icons.merge_type);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  isAr ? 'اختر مستندين أو أكثر للدمج' : 'Select 2+ documents to merge',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: eligible.length,
                  itemBuilder: (_, i) {
                    final doc = eligible[i];
                    return CheckboxListTile(
                      value: _selected.contains(doc.id),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(doc.id);
                          } else {
                            _selected.remove(doc.id);
                          }
                        });
                      },
                      title: Text(doc.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(isAr ? '${doc.pageCount} صفحة' : '${doc.pageCount} pages'),
                      secondary: const Icon(Icons.picture_as_pdf),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LoadingButton(
                    isLoading: _isMerging,
                    isEnabled: _selected.length >= 2,
                    onPressed: _merge,
                    icon: Icons.merge,
                    idleLabel: isAr
                        ? 'دمج (${_selected.length})'
                        : 'Merge (${_selected.length})',
                    loadingLabel: isAr ? 'جاري الدمج...' : 'Merging...',
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

