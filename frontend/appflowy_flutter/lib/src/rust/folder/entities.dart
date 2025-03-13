// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `clone`, `clone`, `fmt`, `fmt`, `fmt`, `fmt`

class FolderIcon {
  final int ty;
  final String value;

  const FolderIcon({
    required this.ty,
    required this.value,
  });

  @override
  int get hashCode => ty.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderIcon &&
          runtimeType == other.runtimeType &&
          ty == other.ty &&
          value == other.value;
}

class FolderListResponse {
  final FolderView data;
  final int code;
  final String message;

  const FolderListResponse({
    required this.data,
    required this.code,
    required this.message,
  });

  @override
  int get hashCode => data.hashCode ^ code.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderListResponse &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          code == other.code &&
          message == other.message;
}

class FolderView {
  final String viewId;
  final String name;
  final FolderIcon? icon;
  final bool isSpace;
  final bool isPrivate;
  final bool isPublished;
  final int layout;
  final String createdAt;
  final String lastEditedTime;
  final bool? isLocked;
  final FolderViewExtra? extra;
  final List<FolderView> children;

  const FolderView({
    required this.viewId,
    required this.name,
    this.icon,
    required this.isSpace,
    required this.isPrivate,
    required this.isPublished,
    required this.layout,
    required this.createdAt,
    required this.lastEditedTime,
    this.isLocked,
    this.extra,
    required this.children,
  });

  @override
  int get hashCode =>
      viewId.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      isSpace.hashCode ^
      isPrivate.hashCode ^
      isPublished.hashCode ^
      layout.hashCode ^
      createdAt.hashCode ^
      lastEditedTime.hashCode ^
      isLocked.hashCode ^
      extra.hashCode ^
      children.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderView &&
          runtimeType == other.runtimeType &&
          viewId == other.viewId &&
          name == other.name &&
          icon == other.icon &&
          isSpace == other.isSpace &&
          isPrivate == other.isPrivate &&
          isPublished == other.isPublished &&
          layout == other.layout &&
          createdAt == other.createdAt &&
          lastEditedTime == other.lastEditedTime &&
          isLocked == other.isLocked &&
          extra == other.extra &&
          children == other.children;
}

class FolderViewExtra {
  final bool isSpace;
  final PlatformInt64 spaceCreatedAt;
  final String spaceIcon;
  final String spaceIconColor;
  final int spacePermission;

  const FolderViewExtra({
    required this.isSpace,
    required this.spaceCreatedAt,
    required this.spaceIcon,
    required this.spaceIconColor,
    required this.spacePermission,
  });

  @override
  int get hashCode =>
      isSpace.hashCode ^
      spaceCreatedAt.hashCode ^
      spaceIcon.hashCode ^
      spaceIconColor.hashCode ^
      spacePermission.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderViewExtra &&
          runtimeType == other.runtimeType &&
          isSpace == other.isSpace &&
          spaceCreatedAt == other.spaceCreatedAt &&
          spaceIcon == other.spaceIcon &&
          spaceIconColor == other.spaceIconColor &&
          spacePermission == other.spacePermission;
}
