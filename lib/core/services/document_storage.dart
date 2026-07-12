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
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => ScannedDocument.fromJson(e))
          .where((d) => d.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('DocumentStorage.loadAll error: $e');
      return [];
    }
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

