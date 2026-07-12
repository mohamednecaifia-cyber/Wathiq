import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/scanner/domain/entities/scanned_document.dart';

part 'document_storage.g.dart';

@Riverpod(keepAlive: true)
DocumentStorage documentStorage(DocumentStorageRef ref) {
  return DocumentStorage();
}

class DocumentStorage {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/documents.json');
  }

  Future<List<ScannedDocument>> loadAll() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final decoded = json.decode(content);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => ScannedDocument(
                id: (e['id'] as String?) ?? '',
                name: (e['name'] as String?) ?? '',
                pdfPath: (e['pdfPath'] as String?) ?? '',
                createdAt: e['createdAt'] != null
                    ? DateTime.tryParse(e['createdAt'] as String) ??
                        DateTime.now()
                    : DateTime.now(),
                ocrText: e['ocrText'] as String?,
                pageCount: (e['pageCount'] as int?) ?? 1,
                sourceImagePaths: (e['sourceImagePaths'] as List<dynamic>?)
                    ?.whereType<String>()
                    .toList(),
              ))
          .where((d) => d.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<ScannedDocument> documents) async {
    try {
      final file = await _file;
      final content = json.encode(
        documents
            .map((d) => {
                  'id': d.id,
                  'name': d.name,
                  'pdfPath': d.pdfPath,
                  'createdAt': d.createdAt.toIso8601String(),
                  'ocrText': d.ocrText,
                  'pageCount': d.pageCount,
                  if (d.sourceImagePaths != null) 'sourceImagePaths': d.sourceImagePaths,
                })
            .toList(),
      );
      await file.writeAsString(content);
    } catch (_) {}
  }
}
