// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../viewer/presentation/screens/viewer_screen.dart';

class ImagesToPdfScreen extends StatefulWidget {
  const ImagesToPdfScreen({super.key});

  @override
  State<ImagesToPdfScreen> createState() => _ImagesToPdfScreenState();
}

class _ImagesToPdfScreenState extends State<ImagesToPdfScreen> {
  final List<String> _imagePaths = [];
  bool _isConverting = false;

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _imagePaths.addAll(result.files.map((f) => f.path!).where((p) => p.isNotEmpty));
      });
    }
  }

  Future<void> _convertToPdf() async {
    if (_imagePaths.isEmpty) return;
    setState(() => _isConverting = true);

    try {
      final fileName = FileUtils.generateFileName();
      final pdfFile = await FileUtils.createPdfFromImages(
        imagePaths: _imagePaths,
        fileName: fileName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved: $fileName')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerScreen(
            pdfPath: pdfFile.path,
            title: fileName.replaceAll('.pdf', ''),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isConverting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'صور إلى PDF' : 'Images to PDF'),
          centerTitle: true,
          actions: _imagePaths.isNotEmpty
              ? [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    tooltip: isAr ? 'إضافة صور' : 'Add images',
                    onPressed: _pickImages,
                  ),
                ]
              : null,
        ),
        body: Stack(
          children: [
            _imagePaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories,
                            size: 80, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          isAr ? 'اختر صوراً لتحويلها إلى PDF'
                              : 'Select images to convert to PDF',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? 'مثل صفحات كتاب أو مستند'
                              : 'Like book pages or a document',
                          style:
                              TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(isAr ? 'اختيار صور' : 'Pick Images'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '${_imagePaths.length} ${isAr ? 'صورة' : 'images'}',
                              style: theme.textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              isAr ? 'اسحب لإعادة الترتيب' : 'Drag to reorder',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: _imagePaths.length,
                          onReorder: (oldI, newI) {
                            setState(() {
                              if (newI > oldI) newI--;
                              final item = _imagePaths.removeAt(oldI);
                              _imagePaths.insert(newI, item);
                            });
                          },
                          itemBuilder: (_, i) {
                            final path = _imagePaths[i];
                            final name = path.split(RegExp(r'[\\/]')).last;
                            return Dismissible(
                              key: ValueKey(path),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: theme.colorScheme.error,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(Icons.delete,
                                    color: theme.colorScheme.onError),
                              ),
                              onDismissed: (_) =>
                                  setState(() => _imagePaths.removeAt(i)),
                              child: ListTile(
                                key: ValueKey(path),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(path),
                                      width: 48,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      cacheWidth: 64),
                                ),
                                title: Text(name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                    isAr ? 'الصفحة ${i + 1}' : 'Page ${i + 1}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (i > 0)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward,
                                            size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _imagePaths.insert(
                                                i - 1, _imagePaths.removeAt(i));
                                          });
                                        },
                                      ),
                                    if (i < _imagePaths.length - 1)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward,
                                            size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _imagePaths.insert(
                                                i + 1, _imagePaths.removeAt(i));
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: LoadingButton(
                            isLoading: _isConverting,
                            isEnabled: _imagePaths.isNotEmpty,
                            onPressed: _convertToPdf,
                            icon: Icons.picture_as_pdf,
                            idleLabel: isAr ? 'تحويل إلى PDF' : 'Convert to PDF',
                            loadingLabel: isAr ? 'جاري التحويل...' : 'Converting...',
                          ),
                        ),
                      ),
                    ],
                  ),
            if (_isConverting)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          Text(
                            isAr ? 'جاري إنشاء PDF...' : 'Creating PDF...',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr
                                ? 'يرجى الانتظار حتى اكتمال المعالجة'
                                : 'Please wait while processing',
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

