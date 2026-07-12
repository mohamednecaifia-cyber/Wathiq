// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/utils/image_enhancer.dart';

class FilterSelector extends StatelessWidget {
  final ValueChanged<ImageFilterType> onSelect;
  const FilterSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                isAr ? 'اختر جودة المسح' : 'Choose scan quality',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _FilterOption(
              icon: Icons.auto_fix_high,
              label: isAr ? 'مستند (أبيض وأسود)' : 'Document (B&W)',
              desc: isAr ? 'أفضل للنصوص، تباين عالي' : 'Best for text, high contrast',
              filter: ImageFilterType.documentBw,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.image,
              label: isAr ? 'صورة ملونة' : 'Color Photo',
              desc: isAr ? 'بدون تحسين، الصورة الأصلية' : 'No enhancement, original image',
              filter: ImageFilterType.original,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.blur_on,
              label: isAr ? 'رمادي' : 'Grayscale',
              desc: isAr ? 'درجات رمادي ناعمة' : 'Soft grayscale tones',
              filter: ImageFilterType.grayscale,
              onSelect: onSelect,
            ),
            _FilterOption(
              icon: Icons.brightness_high,
              label: isAr ? 'مُضاء' : 'Brighten',
              desc: isAr ? 'للمستندات الغامقة' : 'For dark or shadowed docs',
              filter: ImageFilterType.brighten,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final ImageFilterType filter;
  final ValueChanged<ImageFilterType> onSelect;

  const _FilterOption({
    required this.icon,
    required this.label,
    required this.desc,
    required this.filter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(desc),
      onTap: () => onSelect(filter),
    );
  }
}
