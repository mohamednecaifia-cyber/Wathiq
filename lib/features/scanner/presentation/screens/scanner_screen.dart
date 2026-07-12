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
import '../widgets/filter_selector.dart';
import '../widgets/scan_progress_dialog.dart';

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
      builder: (ctx) => FilterSelector(
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
      builder: (_) => ScanProgressDialog(progress: progressNotifier),
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
