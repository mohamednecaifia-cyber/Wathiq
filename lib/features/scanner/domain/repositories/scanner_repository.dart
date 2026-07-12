// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import '../../../../core/utils/image_enhancer.dart';
import '../entities/scanned_document.dart';

class ScanProgress {
  final String step;
  final int current;
  final int total;
  const ScanProgress({required this.step, this.current = 0, this.total = 0});
}

abstract class ScannerRepository {
  Future<ScannedDocument?> scanAndSavePdf(
    String fileName, {
    ImageFilterType filter = ImageFilterType.documentBw,
    bool useOcr = true,
    bool useFilters = true,
    void Function(ScanProgress)? onProgress,
  });
  Future<List<ScannedDocument>> getAllDocuments();
  Future<void> deleteDocument(String docId);
}

