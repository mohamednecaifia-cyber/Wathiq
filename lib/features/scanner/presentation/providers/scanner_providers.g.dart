// Copyright (c) 2024 Mohammed Nasaifia. All rights reserved.
// Licensed under proprietary license. See LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scannerRepositoryHash() => r'cd9c1d8f75fa6aca570940bc22010cebc7f3831a';

/// See also [scannerRepository].
@ProviderFor(scannerRepository)
final scannerRepositoryProvider =
    AutoDisposeProvider<ScannerRepository>.internal(
  scannerRepository,
  name: r'scannerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScannerRepositoryRef = AutoDisposeProviderRef<ScannerRepository>;
String _$scannerNotifierHash() => r'73dbaf26d65494ab8366920b7dabe312f0dd6e22';

/// See also [ScannerNotifier].
@ProviderFor(ScannerNotifier)
final scannerNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ScannerNotifier, List<ScannedDocument>>.internal(
  ScannerNotifier.new,
  name: r'scannerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannerNotifier = AutoDisposeAsyncNotifier<List<ScannedDocument>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

