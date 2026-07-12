// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/scanned_document.dart';

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
      final docs = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => ScannedDocument.fromJson(e))
          .where((d) => d.id.isNotEmpty)
          .toList();
      await _migrateContentUris(docs);
      return docs;
    } catch (e) {
      debugPrint('DocumentStorage.loadAll error: $e');
      return [];
    }
  }

  Future<void> _migrateContentUris(List<ScannedDocument> docs) async {
    final baseDir = await getApplicationDocumentsDirectory();
    var changed = false;
    for (final doc in docs) {
      if (doc.pdfPath.startsWith('content://')) {
        final migrated = '${baseDir.path}/Wathiq/${doc.name}.pdf';
        try {
          final src = File(doc.pdfPath);
          if (await src.exists()) {
            final dest = File(migrated);
            await dest.create(recursive: true);
            await src.copy(dest.path);
          }
        } catch (_) {}
        final json = doc.toJson();
        json['pdfPath'] = migrated;
        final idx = docs.indexOf(doc);
        docs[idx] = ScannedDocument.fromJson(json);
        changed = true;
      }
    }
    if (changed) await saveAll(docs);
  }

  Future<void> saveAll(List<ScannedDocument> documents) async {
    try {
      final file = await _file;
      final content = json.encode(
        documents.map((d) => d.toJson()).toList(),
      );
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('DocumentStorage.saveAll error: $e');
    }
  }
}

