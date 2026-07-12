// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';

import '../../domain/repositories/scanner_repository.dart';

class ScanProgressDialog extends StatelessWidget {
  final ValueNotifier<ScanProgress> progress;
  const ScanProgressDialog({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScanProgress>(
      valueListenable: progress,
      builder: (context, p, _) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(p.step, style: const TextStyle(fontSize: 14)),
              if (p.total > 0) ...[
                const SizedBox(height: 8),
                Text(
                  isAr ? '${p.current} / ${p.total}' : '${p.current} of ${p.total}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: p.current / p.total),
              ],
              if (p.total == 0 && p.step.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  isAr ? 'قد يستغرق قليلاً على الهواتف الضعيفة' : 'May take a moment on older devices',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
