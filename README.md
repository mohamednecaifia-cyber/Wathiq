<p align="center">
  <a href="README.md"><img src="https://img.shields.io/badge/EN-English-blue?style=for-the-badge" alt="English" /></a>
  <a href="README.ar.md"><img src="https://img.shields.io/badge/AR-العربية-green?style=for-the-badge" alt="العربية" /></a>
</p>

# 📄 Wathiq (وثيق) — Smart Document Scanner & Searchable PDF Generator

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/App_Size-16.9_MB-success?style=for-the-badge" alt="Size" />
  <img src="https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge" alt="License" />
</p>

**Wathiq (وثيق)** is a high-performance, ultra-lightweight offline Document Scanner and Searchable PDF Generator built specifically to run smoothly on resource-constrained devices with 2GB RAM or less.

Most modern scanners are bloated (45MB+), consume massive RAM, and require an internet connection to perform OCR. **Wathiq** shatters these limitations by rewriting the standard scanning pipeline.

---

## 🛠️ Engineering Marvels (What Makes It Special)

Instead of stacking heavy external libraries, **Wathiq** was built with a strict focus on memory efficiency and low-level resource management:

* **⚡ On-the-Fly PDF Streaming:** Standard PDF packages hold image buffers in the device's volatile memory (RAM) before writing to disk, causing instant **Out-Of-Memory (OOM) crashes** on low-end phones. Wathiq bypasses this by utilizing a reactive chunk-by-chunk file stream writing directly to disk.
* **📉 Binary Weight-Loss (16.9 MB):** By configuring an unbundled instance of Google ML Kit, the initial APK size was slashed from **42MB to 16.9MB**, ensuring rapid downloads for users on limited data packets.
* **📐 Anti-Clipping Arabic Typography:** Advanced glyph-reshaping for Arabic text layout (Cairo Font) coupled with dynamic `lineSpacing` calculations to prevent the notorious *Glyph Clipping* bug (where dots like ب, ت, ث are cut off by tight bounding boxes).
* **💾 Modern Scoped Storage:** Saves generated PDFs seamlessly under the public `/Downloads/Wathiq/` folder, ensuring immediate visibility in any File Manager or external PDF readers (like Adobe) without breaking Android 10+ isolation laws.

---

## ✨ Features

* **100% Offline OCR:** Text recognition happens locally on the device using Google ML Kit.
* **Zero RAM Lag:** Cleans up compressed temporary `.jpg` cache files instantly via asynchronous background tasks.
* **Fail-Safe UI Architecture:** State management designed to prevent UI freezing during text processing; errors are safely contained within dialog handlers.
* **Zero Memory Leaks:** 100% clean disposal of state handles and runtime references.
* **Merge PDF:** Combine multiple scanned documents into a single PDF by merging their source images.
* **Compress PDF:** Re-encode scanned pages at lower resolution and JPEG quality to drastically reduce file size.
* **Text Extraction:** Copy OCR-recognized text from any scanned document with one tap.
* **Images to PDF:** Import photos from the gallery and convert them directly to PDF.

---

## 📸 Screenshots & UI

| Scan Screen (Camera) | OCR Processing | PDF Document Saved |
|:---:|:---:|:---:|
| <img src="https://via.placeholder.com/200x400?text=Camera+UI" width="200" /> | <img src="https://via.placeholder.com/200x400?text=OCR+Processing" width="200" /> | <img src="https://via.placeholder.com/200x400?text=File+Saved" width="200" /> |

---

## 📥 Installation & Device Compatibility

Wathiq is designed to adapt to the user's specific hardware ecosystem:

### 📱 Low-End & Medium Phones (e.g., Redmi 9A, Samsung A0x)
* **Requirements:** Android 6.0 (API 23) or higher, **Google Play Services (GMS)** installed.
* **First-Run Note:** Since the OCR model is unbundled to save application space, the device needs a brief internet connection on the **very first scan** to download the lightweight language pack. Subsequent scans work completely offline forever.

### 🚫 Non-GMS Devices (Modern Huawei Phones)
* *Note:* The core scanner and image compression work perfectly, but the text-recognition layer will gracefully notify the user about missing Google Core dependencies instead of crashing.

### 🚀 Quick Install

**⬇️ Download the latest APK from the [Releases page](https://github.com/mohamednecaifia-cyber/Wathiq/releases/latest).**

Choose the right variant for your device:

| Variant | CPU | File Size | Recommended For |
|---------|-----|-----------|-----------------|
| `armeabi-v7a` | 32-bit ARM | 16.9 MB | Redmi 9A, low-end Android phones |
| `arm64-v8a` | 64-bit ARM | 18.9 MB | Modern Samsung, Xiaomi, Pixel |
| `universal` | All architectures | ~20 MB | If unsure which variant to pick |

1. Download the appropriate `.apk` file from the [Releases page](https://github.com/mohamednecaifia-cyber/Wathiq/releases/latest).
2. Open it on your device and tap **Install**.
3. On first scan, the OCR model will download once (requires internet). After that, everything works **100% offline**.

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── models/          # Data models (OcrResult, ScanProgress)
│   ├── services/        # Document storage (JSON persistence)
│   ├── theme/           # Material 3 theming (Cairo font, colors)
│   └── utils/           # Core utilities
│       ├── file_utils.dart          # PDF generation & streaming
│       ├── image_enhancer.dart      # Isolate-powered image processing
│       ├── arabic_text_processor.dart # Arabic reshaping & bidi
│       └── document_actions.dart    # Share, save, print
├── features/
│   ├── scanner/          # Scan, OCR, document list
│   ├── viewer/           # PDF preview (printing package)
│   ├── tools/            # Merge, Compress, Images-to-PDF, Text extraction
│   └── settings/         # Dark mode, OCR toggle, filter toggle
└── main.dart             # App entry point with ProviderScope
```

**Key Design Decisions:**
- **Feature-first Clean Architecture** — each feature is self-contained with its own data/domain/presentation layers
- **Riverpod + Code Generation** — type-safe, testable dependency injection with zero boilerplate
- **Background Isolates** — all image processing (enhancement, resizing, compression) runs in `Isolate.run()` to keep the UI thread free
- **PDF Streaming via Temp Files** — images are written as temp JPEGs, `pw.Document` build closures read them lazily during `pdf.save()`, then cleanup runs in a `finally` block

---

## 👨‍💻 Developer & Intellectual Property

This software architecture, resource-tuning pipeline, and source code were structured, refactored, and audited under the absolute ownership of:

**👑 Developed by: Mohammed Nasaifia**

> **Disclaimer:** *All rights reserved. The low-overhead asynchronous stream handling, anti-clipping Arabic typography engine, and memory-conscious PDF pipeline implemented in this repository represent proprietary architectural solutions for high-performance mobile computing.*

---

## 📄 License

Proprietary — All Rights Reserved. See the [LICENSE](LICENSE) file for details.
