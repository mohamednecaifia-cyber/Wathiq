import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../../core/models/ocr_result.dart';
import '../../../../core/utils/image_enhancer.dart';

abstract class OcrDataSource {
  Future<List<OcrResult>> processImages(
    List<String> imagePaths, {
    void Function(String, int, int)? onProgress,
  });
}

class OcrDataSourceImpl implements OcrDataSource {
  @override
  Future<List<OcrResult>> processImages(
    List<String> imagePaths, {
    void Function(String, int, int)? onProgress,
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final results = <OcrResult>[];

    try {
      for (int i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        onProgress?.call('التعرف على النص', i + 1, imagePaths.length);

        final tempPath = await _resizeForOcr(path);
        final inputImage = InputImage.fromFilePath(tempPath);

        final recognizedText = await _processWithRetry(recognizer, inputImage);

        double scaleX, scaleY;
        int imgW, imgH;
        {
          final tempBytes = await File(tempPath).readAsBytes();
          final tempDecoded = img.decodeImage(tempBytes);
          if (tempDecoded == null) {
            await File(tempPath).delete();
            continue;
          }
          final origBytes = await File(path).readAsBytes();
          final origDecoded = img.decodeImage(origBytes);
          if (origDecoded == null) {
            await File(tempPath).delete();
            continue;
          }
          scaleX = origDecoded.width / tempDecoded.width;
          scaleY = origDecoded.height / tempDecoded.height;
          imgW = origDecoded.width;
          imgH = origDecoded.height;
        }

        final words = <OcrWord>[];
        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            for (final element in line.elements) {
              final r = element.boundingBox;
              words.add(OcrWord(
                text: element.text,
                left: (r.left * scaleX) / imgW,
                top: (r.top * scaleY) / imgH,
                width: (r.width * scaleX) / imgW,
                height: (r.height * scaleY) / imgH,
              ));
            }
          }
        }

        results.add(OcrResult(
          imagePath: path,
          imageWidth: imgW,
          imageHeight: imgH,
          words: words,
        ));

        await File(tempPath).delete();
      }
    } finally {
      recognizer.close();
    }

    return results;
  }

  Future<RecognizedText> _processWithRetry(
      TextRecognizer recognizer, InputImage image) async {
    try {
      return await recognizer.processImage(image);
    } catch (e) {
      if (e.toString().contains('model') ||
          e.toString().contains('download') ||
          e.toString().contains('Module') ||
          e.toString().contains('not yet available')) {
        throw Exception(
            'جاري تهيئة محرك التعرف على النص لأول مرة فقط، يرجى المحاولة بعد قليل');
      }
      rethrow;
    }
  }

  Future<String> _resizeForOcr(String originalPath) async {
    final bytes = await ImageEnhancer.resizeForOcr(originalPath);
    final dir = await getTemporaryDirectory();
    final tempPath =
        '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}_${originalPath.hashCode}.jpg';
    await File(tempPath).writeAsBytes(bytes);
    return tempPath;
  }
}