// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/document_storage.dart';
import '../../../../core/services/file_utils_pdf_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../data/datasources/scanner_local_ds.dart';
import '../../data/repositories/scanner_repo_impl.dart';
import '../../../../core/models/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';

part 'scanner_providers.g.dart';

@riverpod
PdfService pdfService(PdfServiceRef ref) {
  return FileUtilsPdfService();
}

@riverpod
ScannerRepository scannerRepository(ScannerRepositoryRef ref) {
  return ScannerRepositoryImpl(
    localDataSource: ScannerLocalDataSourceImpl(),
    ocrDataSource: OcrDataSourceImpl(),
    storage: ref.watch(documentStorageProvider),
    pdfService: ref.watch(pdfServiceProvider),
  );
}

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  @override
  FutureOr<List<ScannedDocument>> build() async {
    final repo = ref.read(scannerRepositoryProvider);
    return repo.getAllDocuments();
  }

  Future<ScannedDocument?> performScan(String fileName,
      {ImageFilterType filter = ImageFilterType.documentBw,
      void Function(ScanProgress)? onProgress}) async {
    final repo = ref.read(scannerRepositoryProvider);
    final settings = ref.read(appSettingsNotifierProvider);
    final doc = await repo.scanAndSavePdf(fileName,
        filter: filter,
        useOcr: settings.useOcr,
        useFilters: settings.useFilters,
        onProgress: onProgress);
    state = AsyncValue.data(await repo.getAllDocuments());
    return doc;
  }

  Future<void> deleteDocument(String docId) async {
    final repo = ref.read(scannerRepositoryProvider);
    await repo.deleteDocument(docId);
    state = AsyncValue.data(await repo.getAllDocuments());
  }

  Future<void> restoreDocument(ScannedDocument doc, int index) async {
    final repo = ref.read(scannerRepositoryProvider);
    await repo.restoreDocument(doc, index);
    state = AsyncValue.data(await repo.getAllDocuments());
  }
}
