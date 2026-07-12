// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/models/ocr_result.dart';
import '../../../../core/services/document_storage.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../domain/entities/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/scanner_local_ds.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerLocalDataSource localDataSource;
  final OcrDataSource ocrDataSource;
  final DocumentStorage storage;

  ScannerRepositoryImpl({
    required this.localDataSource,
    required this.ocrDataSource,
    required this.storage,
  });

  @override
  Future<ScannedDocument?> scanAndSavePdf(
    String fileName, {
    ImageFilterType filter = ImageFilterType.documentBw,
    bool useOcr = true,
    bool useFilters = true,
    void Function(ScanProgress)? onProgress,
  }) async {
    onProgress?.call(const ScanProgress(step: 'مسح المستندات...', current: 0));

    final imagePaths = await localDataSource.scanDocuments();
    if (imagePaths.isEmpty) return null;

    List<String> finalPaths = imagePaths;

    if (useFilters && filter != ImageFilterType.original) {
      finalPaths = await _applyEnhancement(imagePaths, filter, onProgress);
    }

    List<OcrResult> ocrResults = [];
    if (useOcr) {
      ocrResults = await ocrDataSource.processImages(
        finalPaths,
        onProgress: (step, current, total) =>
            onProgress?.call(ScanProgress(step: step, current: current, total: total)),
      );
    }

    onProgress?.call(const ScanProgress(step: 'إنشاء PDF...', current: 0));

    final pdfFileName = FileUtils.generateFileName();

    final pdfFile = useOcr
        ? await FileUtils.createSearchablePdf(
            imagePaths: finalPaths,
            ocrResults: ocrResults,
            fileName: pdfFileName,
          )
        : await FileUtils.createPdfFromImages(
            imagePaths: finalPaths,
            fileName: pdfFileName,
          );

    final ocrText = ocrResults.map((r) => r.words.map((w) => w.text).join(' ')).join('\n');

    final now = DateTime.now();
    final docId = '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';

    final baseDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${baseDir.path}/WathiqImages/$docId');
    await imagesDir.create(recursive: true);

    final persistentPaths = <String>[];
    for (final p in finalPaths) {
      final name = p.split(RegExp(r'[\\/]')).last;
      final dest = '${imagesDir.path}/$name';
      try {
        await File(p).copy(dest);
        persistentPaths.add(dest);
      } catch (_) {
        persistentPaths.add(p);
      }
    }

    final doc = ScannedDocument(
      id: docId,
      name: fileName,
      pdfPath: pdfFile.path,
      createdAt: now,
      ocrText: ocrText.isNotEmpty ? ocrText : null,
      pageCount: finalPaths.length,
      sourceImagePaths: persistentPaths,
    );

    onProgress?.call(const ScanProgress(step: 'جاري الحفظ...'));

    final all = await storage.loadAll();
    all.insert(0, doc);
    await storage.saveAll(all);

    await _cleanupTempFiles(imagePaths, finalPaths);

    return doc;
  }

  Future<List<String>> _applyEnhancement(
    List<String> paths,
    ImageFilterType filter,
    void Function(ScanProgress)? onProgress,
  ) async {
    final enhanced = <String>[];
    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      onProgress?.call(ScanProgress(step: 'تحسين الصورة', current: i + 1, total: paths.length));
      final bytes = await ImageEnhancer.enhance(imagePath: path, filter: filter);
      final base = path.replaceAll(RegExp(r'\.[^.]+$'), '');
      final newPath = '${base}_enhanced.jpg';
      await File(newPath).writeAsBytes(bytes);
      enhanced.add(newPath);
    }
    return enhanced;
  }

  Future<void> _cleanupTempFiles(List<String> original, List<String> enhanced) async {
    for (final path in {...original, ...enhanced}) {
      try { await File(path).delete(); } catch (_) {}
    }
  }

  @override
  Future<List<ScannedDocument>> getAllDocuments() async {
    final docs = await storage.loadAll();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  @override
  Future<void> deleteDocument(String docId) async {
    final all = await storage.loadAll();
    final idx = all.indexWhere((d) => d.id == docId);
    if (idx < 0) return;
    final doc = all.removeAt(idx);
    try {
      final file = File(doc.pdfPath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${baseDir.path}/WathiqImages/$docId');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
    await storage.saveAll(all);
  }
}
