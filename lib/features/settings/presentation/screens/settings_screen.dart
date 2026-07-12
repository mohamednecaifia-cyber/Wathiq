import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsNotifierProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(isAr ? 'المظهر' : 'Appearance', cs),
          Card(
            child: SwitchListTile(
              title: Text(isAr ? 'الوضع الداكن' : 'Dark Mode'),
              subtitle: Text(isAr ? 'تبديل بين الفاتح والداكن' : 'Switch light/dark theme'),
              secondary: Icon(
                settings.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (_) =>
                  ref.read(appSettingsNotifierProvider.notifier).toggleDarkMode(),
            ),
          ),
          const SizedBox(height: 24),
          _header(isAr ? 'المسح' : 'Scanning', cs),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(isAr ? 'التعرف على النص (OCR)' : 'Text Recognition (OCR)'),
                  subtitle:
                      Text(isAr ? 'يجعل النص قابلاً للبحث في PDF' : 'Makes text searchable in PDF'),
                  secondary: const Icon(Icons.text_fields),
                  value: settings.useOcr,
                  onChanged: (_) =>
                      ref.read(appSettingsNotifierProvider.notifier).toggleOcr(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(isAr ? 'تحسين الصورة' : 'Image Enhancement'),
                  subtitle: Text(isAr ? 'تطبيق فلاتر تلقائية' : 'Auto-apply enhancement filters'),
                  secondary: const Icon(Icons.auto_fix_high),
                  value: settings.useFilters,
                  onChanged: (_) =>
                      ref.read(appSettingsNotifierProvider.notifier).toggleFilters(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _header(isAr ? 'حول' : 'About', cs),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(isAr ? 'وثيقة' : 'Wathiq'),
                  subtitle: Text(isAr ? 'الإصدار 1.0.0' : 'Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: Text(isAr ? 'تطبيق مجاني بالكامل' : 'Completely free app'),
                  subtitle: Text(isAr ? 'لا إعلانات ولا اشتراكات' : 'No ads, no subscriptions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          )),
    );
  }
}
