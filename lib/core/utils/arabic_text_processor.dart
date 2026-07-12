// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

class ArabicTextProcessor {
  static final _reshaper = ArabicReshaper(
    configuration: const ArabicReshaperConfig(
      deleteHarakat: true,
      deleteTatweel: true,
      supportLigatures: true,
    ),
  );

  static String process(String text) {
    if (text.isEmpty) return text;
    final reshaped = _reshaper.reshape(text);
    return String.fromCharCodes(bidi.logicalToVisual(reshaped));
  }
}

