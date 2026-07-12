// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfServiceHash() => r'd483bf0a6c8e2ba18bab3391d869a8f9c8089861';

/// See also [pdfService].
@ProviderFor(pdfService)
final pdfServiceProvider = AutoDisposeProvider<PdfService>.internal(
  pdfService,
  name: r'pdfServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pdfServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PdfServiceRef = AutoDisposeProviderRef<PdfService>;
String _$scannerRepositoryHash() => r'06d0464285a603d1dd99624cb378db5cef41b24d';

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
String _$scannerNotifierHash() => r'bfd3223e9e114af269549fa5d86b8110812cd354';

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
