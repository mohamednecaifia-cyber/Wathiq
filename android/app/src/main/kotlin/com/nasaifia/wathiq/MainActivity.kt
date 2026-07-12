package com.nasaifia.wathiq

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nasaifia.wathiq/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveFile") {
                val fileName = call.argument<String>("fileName") ?: run {
                    result.error("INVALID", "fileName required", null); return@setMethodCallHandler
                }
                val bytes = call.argument<ByteArray>("bytes") ?: run {
                    result.error("INVALID", "bytes required", null); return@setMethodCallHandler
                }
                try {
                    val path = saveToDownloads(fileName, bytes)
                    result.success(path)
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(fileName: String, bytes: ByteArray): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return saveViaMediaStore(fileName, bytes)
        }
        return saveLegacy(fileName, bytes)
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun saveViaMediaStore(fileName: String, bytes: ByteArray): String {
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw Exception("Failed to create MediaStore entry")
        contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
            ?: throw Exception("Failed to write file")
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        contentResolver.update(uri, values, null, null)
        return uri.toString()
    }

    private fun saveLegacy(fileName: String, bytes: ByteArray): String {
        val dir = File(Environment.getExternalStorageDirectory(), "Download/Wathiq")
        dir.mkdirs()
        val file = File(dir, fileName)
        file.writeBytes(bytes)
        return file.absolutePath
    }
}
