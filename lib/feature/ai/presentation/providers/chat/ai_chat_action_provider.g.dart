// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiStatus)
const aiStatusProvider = AiStatusProvider._();

final class AiStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const AiStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiStatusHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return aiStatus(ref);
  }
}

String _$aiStatusHash() => r'b98885c6a1b35649dcb576b5063e08ea12d34800';

@ProviderFor(aiChatActionDatasource)
const aiChatActionDatasourceProvider = AiChatActionDatasourceProvider._();

final class AiChatActionDatasourceProvider
    extends
        $FunctionalProvider<
          AiChatActionDatasource,
          AiChatActionDatasource,
          AiChatActionDatasource
        >
    with $Provider<AiChatActionDatasource> {
  const AiChatActionDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiChatActionDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiChatActionDatasourceHash();

  @$internal
  @override
  $ProviderElement<AiChatActionDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiChatActionDatasource create(Ref ref) {
    return aiChatActionDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiChatActionDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiChatActionDatasource>(value),
    );
  }
}

String _$aiChatActionDatasourceHash() =>
    r'062973391994e8a309f34d36e40ebac8377c1f6e';

@ProviderFor(aiChatActionRepository)
const aiChatActionRepositoryProvider = AiChatActionRepositoryProvider._();

final class AiChatActionRepositoryProvider
    extends
        $FunctionalProvider<
          AiChatActionRepository,
          AiChatActionRepository,
          AiChatActionRepository
        >
    with $Provider<AiChatActionRepository> {
  const AiChatActionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiChatActionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiChatActionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiChatActionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiChatActionRepository create(Ref ref) {
    return aiChatActionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiChatActionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiChatActionRepository>(value),
    );
  }
}

String _$aiChatActionRepositoryHash() =>
    r'572065a5d829ff9a010a557f4e62d1d87c1565d0';

@ProviderFor(AiChatAction)
const aiChatActionProvider = AiChatActionFamily._();

final class AiChatActionProvider
    extends $NotifierProvider<AiChatAction, AiChatActionState> {
  const AiChatActionProvider._({
    required AiChatActionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'aiChatActionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$aiChatActionHash();

  @override
  String toString() {
    return r'aiChatActionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AiChatAction create() => AiChatAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiChatActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiChatActionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AiChatActionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiChatActionHash() => r'0f2ee0697014f54d8105d3d5903ce6e19dc73cd6';

final class AiChatActionFamily extends $Family
    with
        $ClassFamilyOverride<
          AiChatAction,
          AiChatActionState,
          AiChatActionState,
          AiChatActionState,
          String
        > {
  const AiChatActionFamily._()
    : super(
        retry: null,
        name: r'aiChatActionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AiChatActionProvider call({required String packageName}) =>
      AiChatActionProvider._(argument: packageName, from: this);

  @override
  String toString() => r'aiChatActionProvider';
}

abstract class _$AiChatAction extends $Notifier<AiChatActionState> {
  late final _$args = ref.$arg as String;
  String get packageName => _$args;

  AiChatActionState build({required String packageName});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(packageName: _$args);
    final ref = this.ref as $Ref<AiChatActionState, AiChatActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AiChatActionState, AiChatActionState>,
              AiChatActionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
