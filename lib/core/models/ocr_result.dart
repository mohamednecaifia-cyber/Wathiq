// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

class OcrWord {
  final String text;
  final double left;
  final double top;
  final double width;
  final double height;

  OcrWord({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class OcrResult {
  final String imagePath;
  final int imageWidth;
  final int imageHeight;
  final List<OcrWord> words;

  OcrResult({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.words,
  });
}

