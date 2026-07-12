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
}
