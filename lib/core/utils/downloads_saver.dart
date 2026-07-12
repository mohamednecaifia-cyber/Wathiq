import 'dart:io';

import 'package:flutter/services.dart';

class DownloadsSaver {
  static const _channel = MethodChannel('com.nasaifia.wathiq/downloads');

  static Future<String> save(String fileName, List<int> bytes) async {
    try {
      return await _channel.invokeMethod<String>('saveFile', {
        'fileName': fileName,
        'bytes': bytes,
      }) ?? '';
    } catch (_) {
      // Fallback to direct file write
      final dir = Directory('/storage/emulated/0/Download/Wathiq');
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }
}
