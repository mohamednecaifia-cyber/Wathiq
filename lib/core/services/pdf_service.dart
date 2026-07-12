// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:io';

import '../models/ocr_result.dart';

abstract class PdfService {
  String generateFileName();
  Future<File> createPdfFromImages({
    required List<String> imagePaths,
    required String fileName,
  });
  Future<File> createSearchablePdf({
    required List<String> imagePaths,
    required List<OcrResult> ocrResults,
    required String fileName,
  });
}
