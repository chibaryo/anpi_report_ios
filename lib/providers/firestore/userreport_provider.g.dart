// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userreport_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseFirestoreHash() => r'230b9276da2e44bb1aa6b300e1ddbb2f93c422da';

///
///
/// Copied from [firebaseFirestore].
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
String _$prevNotisStreamHash() => r'7fae7d0e1bf6cf6c349ae9620f2cc1a164e4db36';

/// See also [prevNotisStream].
@ProviderFor(prevNotisStream)
final prevNotisStreamProvider =
    AutoDisposeStreamProvider<List<PrevNotis>>.internal(
  prevNotisStream,
  name: r'prevNotisStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$prevNotisStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PrevNotisStreamRef = AutoDisposeStreamProviderRef<List<PrevNotis>>;
String _$asyncUserReportNotifierHash() =>
    r'2e4ea2dd122eba250465b9996ea50dbff891048e';

/// See also [AsyncUserReportNotifier].
@ProviderFor(AsyncUserReportNotifier)
final asyncUserReportNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AsyncUserReportNotifier, List<UserReport>>.internal(
  AsyncUserReportNotifier.new,
  name: r'asyncUserReportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$asyncUserReportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AsyncUserReportNotifier = AutoDisposeAsyncNotifier<List<UserReport>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
