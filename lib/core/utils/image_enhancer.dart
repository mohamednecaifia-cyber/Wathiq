import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ImageFilterType {
  original,
  autoEnhance,
  documentBw,
  grayscale,
  brighten,
}

class ProcessRequest {
  final String imagePath;
  final ImageFilterType? filter;
  final bool needsOcrResize;
  final bool needsPdfDownscale;

  const ProcessRequest({
    required this.imagePath,
    this.filter,
    this.needsOcrResize = false,
    this.needsPdfDownscale = false,
  });
}

class ProcessResult {
  final String imagePath;
  final List<int>? enhancedBytes;
  final List<int>? ocrResizedBytes;
  final List<int>? pdfDownscaleBytes;

  const ProcessResult({
    required this.imagePath,
    this.enhancedBytes,
    this.ocrResizedBytes,
    this.pdfDownscaleBytes,
  });
}

enum _Op { enhance, resizeOcr, downscale }

class _Task {
  final String imagePath;
  final _Op op;
  final ImageFilterType? filter;
  const _Task(this.imagePath, this.op, this.filter);
}

class ImageEnhancer {
  static const _maxDimension = 1600;
  static const _pdfMaxDimension = 2000;
  static const _pdfQuality = 85;

  static Future<Uint8List> enhance({
    required String imagePath,
    required ImageFilterType filter,
  }) async {
    return Isolate.run(() => _exec(_Task(imagePath, _Op.enhance, filter)));
  }

  static Future<Uint8List> resizeForOcr(String imagePath) async {
    return Isolate.run(() => _exec(_Task(imagePath, _Op.resizeOcr, null)));
  }

  static Future<Uint8List> downscaleForPdf(String imagePath) async {
    return Isolate.run(() => _exec(_Task(imagePath, _Op.downscale, null)));
  }

  static Future<Uint8List> compress(String imagePath, {int maxDimension = 1200, int quality = 60}) async {
    return Isolate.run(() {
      try {
        final bytes = File(imagePath).readAsBytesSync();
        final image = img.decodeImage(bytes);
        if (image == null) return bytes;
        final resized = image.width > maxDimension || image.height > maxDimension
            ? img.copyResize(image, width: maxDimension)
            : image;
        return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      } catch (_) {
        return File(imagePath).readAsBytesSync();
      }
    });
  }

  static Uint8List _exec(_Task t) {
    try {
      final bytes = File(t.imagePath).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      List<int> out;
      switch (t.op) {
        case _Op.enhance:
          out = img.encodeJpg(_applyFilter(image, t.filter ?? ImageFilterType.documentBw), quality: 92);
        case _Op.resizeOcr:
          final resized = image.width > _maxDimension || image.height > _maxDimension
              ? img.copyResize(image, width: _maxDimension)
              : image;
          out = img.encodeJpg(resized, quality: 85);
        case _Op.downscale:
          final resized = image.width > _pdfMaxDimension || image.height > _pdfMaxDimension
              ? img.copyResize(image, width: _pdfMaxDimension)
              : image;
          out = img.encodeJpg(resized, quality: _pdfQuality);
      }
      return Uint8List.fromList(out);
    } catch (_) {
      return File(t.imagePath).readAsBytesSync();
    }
  }

  static Future<ProcessResult> processImage({
    required String imagePath,
    ImageFilterType? filter,
    bool needsOcrResize = false,
    bool needsPdfDownscale = false,
  }) async {
    return Isolate.run(() => _processSync(ProcessRequest(
      imagePath: imagePath,
      filter: filter,
      needsOcrResize: needsOcrResize,
      needsPdfDownscale: needsPdfDownscale,
    )));
  }

  static Future<List<ProcessResult>> processBatch({
    required List<String> imagePaths,
    ImageFilterType? filter,
    bool needsOcrResize = false,
    bool needsPdfDownscale = false,
    void Function(int, int)? onProgress,
  }) async {
    final results = <ProcessResult>[];
    for (int i = 0; i < imagePaths.length; i++) {
      results.add(await processImage(
        imagePath: imagePaths[i],
        filter: filter,
        needsOcrResize: needsOcrResize,
        needsPdfDownscale: needsPdfDownscale,
      ));
      onProgress?.call(i + 1, imagePaths.length);
    }
    return results;
  }

  static ProcessResult _processSync(ProcessRequest req) {
    try {
      final bytes = File(req.imagePath).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) return ProcessResult(imagePath: req.imagePath);

      List<int>? enhancedBytes;
      if (req.filter != null) {
        enhancedBytes = img.encodeJpg(_applyFilter(image, req.filter!), quality: 92);
      }

      List<int>? ocrBytes;
      if (req.needsOcrResize) {
        final resized = image.width > _maxDimension || image.height > _maxDimension
            ? img.copyResize(image, width: _maxDimension)
            : image;
        ocrBytes = img.encodeJpg(resized, quality: 85);
      }

      List<int>? pdfBytes;
      if (req.needsPdfDownscale) {
        final resized = image.width > _pdfMaxDimension || image.height > _pdfMaxDimension
            ? img.copyResize(image, width: _pdfMaxDimension)
            : image;
        pdfBytes = img.encodeJpg(resized, quality: _pdfQuality);
      }

      return ProcessResult(
        imagePath: req.imagePath,
        enhancedBytes: enhancedBytes,
        ocrResizedBytes: ocrBytes,
        pdfDownscaleBytes: pdfBytes,
      );
    } catch (_) {
      return ProcessResult(imagePath: req.imagePath);
    }
  }

  static img.Image _applyFilter(img.Image image, ImageFilterType filter) {
    switch (filter) {
      case ImageFilterType.original:
        return image;
      case ImageFilterType.autoEnhance:
        return img.adjustColor(image,
            contrast: 1.15, saturation: 1.1, brightness: 1.05, gamma: 0.9);
      case ImageFilterType.documentBw:
        return _documentBw(image);
      case ImageFilterType.grayscale:
        return img.grayscale(image);
      case ImageFilterType.brighten:
        return img.adjustColor(image, brightness: 1.15);
    }
  }

  static img.Image _documentBw(img.Image image) {
    final gray = img.grayscale(image);
    final thresh = _otsuThreshold(gray);
    return img.luminanceThreshold(gray,
        threshold: thresh / 255.0, outputColor: false);
  }

  static int _otsuThreshold(img.Image image) {
    final histogram = List<int>.filled(256, 0);
    for (final pixel in image) {
      final lum = pixel.luminance.toInt();
      if (lum >= 0 && lum < 256) {
        histogram[lum] = histogram[lum] + 1;
      }
    }

    final total = image.width * image.height;
    var sum = 0;
    for (var i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }

    var sumB = 0;
    var wB = 0;
    var maxVariance = 0.0;
    var threshold = 0;

    for (var i = 0; i < 256; i++) {
      wB += histogram[i];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;

      sumB += i * histogram[i];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB.toDouble() * wF.toDouble() * (mB - mF) * (mB - mF);

      if (between > maxVariance) {
        maxVariance = between;
        threshold = i;
      }
    }

    return threshold;
  }
}
