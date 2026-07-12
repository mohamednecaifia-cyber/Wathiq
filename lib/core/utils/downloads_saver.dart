import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsSaver {
  static const _channel = MethodChannel('com.nasaifia.wathiq/downloads');

  static Future<String> save(String fileName, List<int> bytes) async {
    final docs = await getApplicationDocumentsDirectory();
    final localDir = Directory('${docs.path}/Wathiq');
    if (!await localDir.exists()) await localDir.create(recursive: true);
    final localFile = File('${localDir.path}/$fileName');
    await localFile.writeAsBytes(bytes);

    try {
      await _channel.invokeMethod<String>('saveFile', {
        'fileName': fileName,
        'bytes': bytes,
      });
    } catch (_) {}

    return localFile.path;
  }
}
