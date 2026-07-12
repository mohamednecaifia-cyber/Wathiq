import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class DocumentActions {
  static Future<void> shareFile(String pdfPath) async {
    await Share.shareXFiles([XFile(pdfPath)]);
  }

  static Future<String?> saveToFiles(BuildContext context, String pdfPath, String fileName) async {
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final result = await FilePicker.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
      );
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: ${result.split(RegExp(r'[\\/]')).last}')),
        );
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
      return null;
    }
  }

  static Future<void> printPdf(String pdfPath) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) => File(pdfPath).readAsBytes(),
      );
    } catch (_) {}
  }
}
