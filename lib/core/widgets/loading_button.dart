// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final IconData icon;
  final String idleLabel;
  final String loadingLabel;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
    required this.icon,
    required this.idleLabel,
    required this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon),
        label: Text(isLoading ? loadingLabel : idleLabel),
      ),
    );
  }
}
