// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import '../models/ocr_result.dart';
import '../utils/file_utils.dart';
import 'pdf_service.dart';

class FileUtilsPdfService implements PdfService {
  @override
  String generateFileName() => FileUtils.generateFileName();

  @override
  Future<File> createPdfFromImages({
    required List<String> imagePaths,
    required String fileName,
  }) {
    return FileUtils.createPdfFromImages(
      imagePaths: imagePaths,
      fileName: fileName,
    );
  }

  @override
  Future<File> createSearchablePdf({
    required List<String> imagePaths,
    required List<OcrResult> ocrResults,
    required String fileName,
  }) {
    return FileUtils.createSearchablePdf(
      imagePaths: imagePaths,
      ocrResults: ocrResults,
      fileName: fileName,
    );
  }
}
