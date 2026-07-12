import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/document_storage.dart';
import '../../../../core/utils/image_enhancer.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../data/datasources/scanner_local_ds.dart';
import '../../data/repositories/scanner_repo_impl.dart';
import '../../domain/entities/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';

part 'scanner_providers.g.dart';

@riverpod
ScannerRepository scannerRepository(ScannerRepositoryRef ref) {
  return ScannerRepositoryImpl(
    localDataSource: ScannerLocalDataSourceImpl(),
    ocrDataSource: OcrDataSourceImpl(),
    storage: ref.watch(documentStorageProvider),
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
}