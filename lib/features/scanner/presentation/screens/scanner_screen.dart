// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../viewer/presentation/screens/viewer_screen.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../../tools/presentation/screens/images_to_pdf_screen.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../providers/scanner_providers.dart';
import '../widgets/document_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsState = ref.watch(scannerNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'المستندات' : 'Documents'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: isAr ? 'استيراد من الملفات' : 'Import from files',
            onPressed: docsState.isLoading ? null : () => _startImport(context),
          ),
        ],
      ),
      body: docsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (docs) => docs.isEmpty
            ? const EmptyStateWidget()
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(scannerNotifierProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return Dismissible(
                      key: Key(doc.id),
                      background: Container(
                        color: cs.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child:
                            const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        final notifier = ref.read(scannerNotifierProvider.notifier);
                        final docs = ref.read(scannerNotifierProvider).valueOrNull ?? [];
                        final idx = docs.indexWhere((d) => d.id == doc.id);
                        await notifier.deleteDocument(doc.id);
                        if (!context.mounted) return true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isAr ? 'تم حذف المستند' : 'Document deleted'),
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: isAr ? 'تراجع' : 'Undo',
                              onPressed: () => notifier.restoreDocument(doc, idx),
                            ),
                          ),
                        );
                        return true;
                      },
                      child: DocumentCard(
                        document: doc,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewerScreen(
                                pdfPath: doc.pdfPath,
                                title: doc.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: docsState.isLoading
            ? null
            : () => _startScan(context, ref),
        icon: docsState.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.camera_alt),
        label: Text(isAr ? 'مسح ضوئي' : 'Scan'),
      ),
    );
  }

  void _startImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImagesToPdfScreen()),
    );
  }

  void _startScan(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSelector(
        onSelect: (filter) {
          Navigator.pop(ctx);
          _performScan(context, ref, filter);
        },
      ),
    );
  }

  void _performScan(
      BuildContext context, WidgetRef ref, ImageFilterType filter) {
    final progressNotifier = ValueNotifier<ScanProgress>(
      const ScanProgress(step: 'جاري تهيئة محرك التعرف على النص...'),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScanProgressDialog(progress: progressNotifier),
    );

    final fileName =
        'doc_${DateTime.now().millisecondsSinceEpoch}';
    final notifier =
        ref.read(scannerNotifierProvider.notifier);

    notifier
        .performScan(fileName,
            filter: filter,
            onProgress: (p) => progressNotifier.value = p)
        .then((result) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (result != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ViewerScreen(
              pdfPath: result.pdfPath,
              title: result.name,
            ),
          ),
        );
      }
    }).catchError((err) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      final isAr =
          Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isAr ? 'فشل المسح: $err' : 'Scan failed: $err'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }
}

class _FilterSelector extends StatelessWidget {
  final ValueChanged<ImageFilterType> onSelect;
  const _FilterSelector({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isAr =
        Localizations.localeOf(context).languageCode == 'ar';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                isAr
                    ? 'اختر جودة المسح'
                    : 'Choose scan quality',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _FilterOption(
              icon: Icons.auto_fix_high,
              label: isAr
                  ? 'مستند (أبيض وأسود)'
                  : 'Document (B&W)',
              desc: isAr
                  ? 'أفضل للنصوص، تباين عالي'
                  : 'Best for text, high contrast',
              filter: ImageFilterType.documentBw,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.image,
              label: isAr ? 'صورة ملونة' : 'Color Photo',
              desc: isAr
                  ? 'بدون تحسين، الصورة الأصلية'
                  : 'No enhancement, original image',
              filter: ImageFilterType.original,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.blur_on,
              label: isAr ? 'رمادي' : 'Grayscale',
              desc: isAr
                  ? 'درجات رمادي ناعمة'
                  : 'Soft grayscale tones',
              filter: ImageFilterType.grayscale,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.brightness_high,
              label: isAr ? 'مُضاء' : 'Brighten',
              desc: isAr
                  ? 'للمستندات الغامقة'
                  : 'For dark or shadowed docs',
              filter: ImageFilterType.brighten,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final ImageFilterType filter;
  final ValueChanged<ImageFilterType> onSelect;

  const _FilterOption({
    required this.icon,
    required this.label,
    required this.desc,
    required this.filter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title:
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(desc),
      onTap: () => onSelect(filter),
    );
  }
}

class _ScanProgressDialog extends StatelessWidget {
  final ValueNotifier<ScanProgress> progress;
  const _ScanProgressDialog({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScanProgress>(
      valueListenable: progress,
      builder: (context, p, _) {
        final isAr =
            Localizations.localeOf(context).languageCode == 'ar';
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(p.step,
                  style: const TextStyle(fontSize: 14)),
              if (p.total > 0) ...[
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? '${p.current} / ${p.total}'
                      : '${p.current} of ${p.total}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: p.current / p.total,
                ),
              ],
              if (p.total == 0 && p.step.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? 'قد يستغرق قليلاً على الهواتف الضعيفة'
                      : 'May take a moment on older devices',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
