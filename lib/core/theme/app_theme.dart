// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color cardBorder,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cardBorder),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => _base(
        brightness: Brightness.light,
        scaffoldBg: AppColors.background,
        cardBorder: Colors.grey.shade200,
      );

  static ThemeData get darkTheme => _base(
        brightness: Brightness.dark,
        scaffoldBg: AppColors.darkBackground,
        cardBorder: Colors.grey.shade800,
      );
}

