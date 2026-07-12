// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

class ScannedDocument {
  final String id;
  final String name;
  final String pdfPath;
  final DateTime createdAt;
  final String? ocrText;
  final int pageCount;
  final List<String>? sourceImagePaths;

  ScannedDocument({
    required this.id,
    required this.name,
    required this.pdfPath,
    required this.createdAt,
    this.ocrText,
    this.pageCount = 1,
    this.sourceImagePaths,
  });

  ScannedDocument copyWith({
    String? id,
    String? name,
    String? pdfPath,
    DateTime? createdAt,
    String? ocrText,
    int? pageCount,
    List<String>? sourceImagePaths,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      pdfPath: pdfPath ?? this.pdfPath,
      createdAt: createdAt ?? this.createdAt,
      ocrText: ocrText ?? this.ocrText,
      pageCount: pageCount ?? this.pageCount,
      sourceImagePaths: sourceImagePaths ?? this.sourceImagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pdfPath': pdfPath,
        'createdAt': createdAt.toIso8601String(),
        'ocrText': ocrText,
        'pageCount': pageCount,
        if (sourceImagePaths != null) 'sourceImagePaths': sourceImagePaths,
      };

  factory ScannedDocument.fromJson(Map<String, dynamic> e) => ScannedDocument(
        id: (e['id'] as String?) ?? '',
        name: (e['name'] as String?) ?? '',
        pdfPath: (e['pdfPath'] as String?) ?? '',
        createdAt: e['createdAt'] != null
            ? DateTime.tryParse(e['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        ocrText: e['ocrText'] as String?,
        pageCount: (e['pageCount'] as int?) ?? 1,
        sourceImagePaths: (e['sourceImagePaths'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(),
      );
}
