// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UiStateCWProxy {
  UiState mediaQueryData(MediaQueryData mediaQueryData);

  UiState currentRoute(List<String> currentRoute);

  UiState action(String action);

  UiState entity(MemoryItem entity);

  UiState isDesktop(bool isDesktop);

  UiState isMenuVisible(bool isMenuVisible);

  UiState isMenuCollapsed(bool isMenuCollapsed);

  UiState isMenuFloated(bool isMenuFloated);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UiState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UiState(...).copyWith(id: 12, name: "My name")
  /// ````
  UiState call({
    MediaQueryData? mediaQueryData,
    List<String>? currentRoute,
    String? action,
    MemoryItem? entity,
    bool? isDesktop,
    bool? isMenuVisible,
    bool? isMenuCollapsed,
    bool? isMenuFloated,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUiState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUiState.copyWith.fieldName(...)`
class _$UiStateCWProxyImpl implements _$UiStateCWProxy {
  const _$UiStateCWProxyImpl(this._value);

  final UiState _value;

  @override
  UiState mediaQueryData(MediaQueryData mediaQueryData) =>
      this(mediaQueryData: mediaQueryData);

  @override
  UiState currentRoute(List<String> currentRoute) =>
      this(currentRoute: currentRoute);

  @override
  UiState action(String action) => this(action: action);

  @override
  UiState entity(MemoryItem entity) => this(entity: entity);

  @override
  UiState isDesktop(bool isDesktop) => this(isDesktop: isDesktop);

  @override
  UiState isMenuVisible(bool isMenuVisible) =>
      this(isMenuVisible: isMenuVisible);

  @override
  UiState isMenuCollapsed(bool isMenuCollapsed) =>
      this(isMenuCollapsed: isMenuCollapsed);

  @override
  UiState isMenuFloated(bool isMenuFloated) =>
      this(isMenuFloated: isMenuFloated);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UiState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UiState(...).copyWith(id: 12, name: "My name")
  /// ````
  UiState call({
    Object? mediaQueryData = const $CopyWithPlaceholder(),
    Object? currentRoute = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
    Object? entity = const $CopyWithPlaceholder(),
    Object? isDesktop = const $CopyWithPlaceholder(),
    Object? isMenuVisible = const $CopyWithPlaceholder(),
    Object? isMenuCollapsed = const $CopyWithPlaceholder(),
    Object? isMenuFloated = const $CopyWithPlaceholder(),
  }) {
    return UiState(
      mediaQueryData: mediaQueryData == const $CopyWithPlaceholder() ||
              mediaQueryData == null
          // ignore: unnecessary_non_null_assertion
          ? _value.mediaQueryData!
          // ignore: cast_nullable_to_non_nullable
          : mediaQueryData as MediaQueryData,
      currentRoute:
          currentRoute == const $CopyWithPlaceholder() || currentRoute == null
              // ignore: unnecessary_non_null_assertion
              ? _value.currentRoute!
              // ignore: cast_nullable_to_non_nullable
              : currentRoute as List<String>,
      action: action == const $CopyWithPlaceholder() || action == null
          // ignore: unnecessary_non_null_assertion
          ? _value.action!
          // ignore: cast_nullable_to_non_nullable
          : action as String,
      entity: entity == const $CopyWithPlaceholder() || entity == null
          // ignore: unnecessary_non_null_assertion
          ? _value.entity!
          // ignore: cast_nullable_to_non_nullable
          : entity as MemoryItem,
      isDesktop: isDesktop == const $CopyWithPlaceholder() || isDesktop == null
          // ignore: unnecessary_non_null_assertion
          ? _value.isDesktop!
          // ignore: cast_nullable_to_non_nullable
          : isDesktop as bool,
      isMenuVisible:
          isMenuVisible == const $CopyWithPlaceholder() || isMenuVisible == null
              // ignore: unnecessary_non_null_assertion
              ? _value.isMenuVisible!
              // ignore: cast_nullable_to_non_nullable
              : isMenuVisible as bool,
      isMenuCollapsed: isMenuCollapsed == const $CopyWithPlaceholder() ||
              isMenuCollapsed == null
          // ignore: unnecessary_non_null_assertion
          ? _value.isMenuCollapsed!
          // ignore: cast_nullable_to_non_nullable
          : isMenuCollapsed as bool,
      isMenuFloated:
          isMenuFloated == const $CopyWithPlaceholder() || isMenuFloated == null
              // ignore: unnecessary_non_null_assertion
              ? _value.isMenuFloated!
              // ignore: cast_nullable_to_non_nullable
              : isMenuFloated as bool,
    );
  }
}

extension $UiStateCopyWith on UiState {
  /// Returns a callable class that can be used as follows: `instanceOfUiState.copyWith(...)` or like so:`instanceOfUiState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UiStateCWProxy get copyWith => _$UiStateCWProxyImpl(this);
}
