// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deviceinfotable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseFirestoreHash() => r'230b9276da2e44bb1aa6b300e1ddbb2f93c422da';

/// See also [firebaseFirestore].
@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider =
    AutoDisposeProvider<FirebaseFirestore>.internal(
  firebaseFirestore,
  name: r'firebaseFirestoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseFirestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseFirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$udidNotifierHash() => r'a1e777fff1cc0b78a29b6a983b7d13b3c5fc6ca0';

/// See also [UdidNotifier].
@ProviderFor(UdidNotifier)
final udidNotifierProvider =
    AutoDisposeNotifierProvider<UdidNotifier, String>.internal(
  UdidNotifier.new,
  name: r'udidNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$udidNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UdidNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
