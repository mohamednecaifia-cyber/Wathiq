import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ocr_result.dart';
import 'arabic_text_processor.dart';
import 'image_enhancer.dart';

class FileUtils {
  static pw.Font? _cachedFont;

  static String generateFileName() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return 'scan_$y$m${d}_$h$min$s.pdf';
  }

  static Future<pw.Font> _getFont() async {
    if (_cachedFont != null) return _cachedFont!;
    try {
      final data =
          await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _cachedFont = pw.Font.ttf(data);
      return _cachedFont!;
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  static Future<File> createPdfFromImages({
    required List<String> imagePaths,
    required String fileName,
  }) async {
    if (imagePaths.isEmpty) {
      throw Exception('No images to convert to PDF');
    }

    final pdf = pw.Document(
      title: fileName,
      author: 'Wathiq Scanner',
      creator: 'Wathiq Scanner',
    );

    final tempDir = await getTemporaryDirectory();
    final cleanup = <String>[];

    try {
      for (final path in imagePaths) {
        final imageFile = File(path);
        if (!await imageFile.exists()) continue;

        final imageBytes = await ImageEnhancer.downscaleForPdf(path);
        final tempPath = '${tempDir.path}/pdf_${path.hashCode}_${DateTime.now().microsecondsSinceEpoch}.jpg';
        await File(tempPath).writeAsBytes(imageBytes);
        cleanup.add(tempPath);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              final bytes = File(tempPath).readAsBytesSync();
              return pw.Center(
                child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      return await _savePdf(pdf, fileName);
    } finally {
      for (final p in cleanup) {
        try { await File(p).delete(); } catch (_) {}
      }
    }
  }

  static Future<File> createSearchablePdf({
    required List<String> imagePaths,
    required List<OcrResult> ocrResults,
    required String fileName,
  }) async {
    if (imagePaths.isEmpty) {
      throw Exception('No images to convert to PDF');
    }

    try {
      return await _buildSearchablePdf(
          imagePaths: imagePaths, ocrResults: ocrResults, fileName: fileName);
    } catch (_) {
      return createPdfFromImages(
          imagePaths: imagePaths, fileName: fileName);
    }
  }

  static Future<File> _buildSearchablePdf({
    required List<String> imagePaths,
    required List<OcrResult> ocrResults,
    required String fileName,
  }) async {
    final pdf = pw.Document(
      title: fileName,
      author: 'Wathiq Scanner',
      creator: 'Wathiq Scanner',
    );
    final font = await _getFont();
    final tempDir = await getTemporaryDirectory();
    final cleanup = <String>[];

    try {
      for (int i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final imageFile = File(path);
        if (!await imageFile.exists()) continue;

        final imageBytes = await ImageEnhancer.downscaleForPdf(path);
        final tempPath = '${tempDir.path}/pdf_${path.hashCode}_${DateTime.now().microsecondsSinceEpoch}.jpg';
        await File(tempPath).writeAsBytes(imageBytes);
        cleanup.add(tempPath);

        final ocr = i < ocrResults.length ? ocrResults[i] : null;
        double imgW = 0, imgH = 0;

        if (ocr != null) {
          imgW = ocr.imageWidth.toDouble();
          imgH = ocr.imageHeight.toDouble();
        }

        final pageW = PdfPageFormat.a4.width;
        final pageH = PdfPageFormat.a4.height;
        final scale = imgW > 0 && imgH > 0
            ? (pageW / imgW < pageH / imgH
                ? pageW / imgW
                : pageH / imgH)
            : 1.0;
        final renderedW = imgW * scale;
        final renderedH = imgH * scale;
        final offsetX = (pageW - renderedW) / 2;
        final offsetY = (pageH - renderedH) / 2;

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              final bytes = File(tempPath).readAsBytesSync();
              return pw.Stack(
                children: [
                  pw.Positioned(
                    left: offsetX,
                    top: offsetY,
                    child:
                        pw.Image(pw.MemoryImage(bytes), width: renderedW, height: renderedH),
                  ),
                  if (ocr != null)
                    ...ocr.words.map((word) {
                      return pw.Positioned(
                        left: offsetX + word.left * imgW * scale,
                        top: offsetY + word.top * imgH * scale,
                        child: pw.SizedBox(
                          width: word.width * imgW * scale * 1.1,
                          height: word.height * imgH * scale,
                            child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                            ArabicTextProcessor.process(word.text),
                            style: pw.TextStyle(
                              font: font,
                              fontSize: word.height * imgH * scale * 0.75,
                              lineSpacing: word.height * imgH * scale * 0.3,
                              color: const PdfColor.fromInt(0x01FFFFFF),
                            ),
                          ),),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        );
      }

      return await _savePdf(pdf, fileName);
    } finally {
      for (final p in cleanup) {
        try { await File(p).delete(); } catch (_) {}
      }
    }
  }

  static Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final safeName = _sanitize(fileName);
    final bytes = await pdf.save();

    // Try public Downloads/Wathiq first
    try {
      final downloadDir = Directory('/storage/emulated/0/Download/Wathiq');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      final file = File('${downloadDir.path}/$safeName');
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      // Fall back to app-private directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  static String _sanitize(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(' ', '_');
  }
}
