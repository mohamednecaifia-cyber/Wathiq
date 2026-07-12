// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PdfScannerApp()));
}

