import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool useOcr;
  final bool useFilters;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.useOcr = true,
    this.useFilters = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? useOcr,
    bool? useFilters,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      useOcr: useOcr ?? this.useOcr,
      useFilters: useFilters ?? this.useFilters,
    );
  }
}

@Riverpod(keepAlive: true)
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  void toggleDarkMode() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }

  void toggleOcr() {
    state = state.copyWith(useOcr: !state.useOcr);
  }

  void toggleFilters() {
    state = state.copyWith(useFilters: !state.useFilters);
  }
}
