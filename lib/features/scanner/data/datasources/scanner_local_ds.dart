// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

abstract class ScannerLocalDataSource {
  Future<List<String>> scanDocuments();
}

class ScannerLocalDataSourceImpl implements ScannerLocalDataSource {
  @override
  Future<List<String>> scanDocuments() async {
    final options = DocumentScannerOptions(
      mode: ScannerMode.full,
      pageLimit: 20,
      isGalleryImport: true,
    );

    final documentScanner = DocumentScanner(options: options);

    try {
      final result = await documentScanner.scanDocument();
      documentScanner.close();
      return result.images ?? [];
    } catch (e) {
      documentScanner.close();
      throw Exception('Failed to scan documents: $e');
    }
  }
}

