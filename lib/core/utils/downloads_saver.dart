import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsSaver {
  static const _channel = MethodChannel('com.nasaifia.wathiq/downloads');

  static Future<String> save(String fileName, List<int> bytes) async {
    try {
      return await _channel.invokeMethod<String>('saveFile', {
        'fileName': fileName,
        'bytes': bytes,
      }) ?? '';
    } catch (_) {
      final dir = await _downloadDir();
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  static Future<Directory> _downloadDir() async {
    try {
      final dir = Directory('/storage/emulated/0/Download/Wathiq');
      if (await dir.exists()) return dir;
    } catch (_) {}
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/Wathiq');
  }
}
