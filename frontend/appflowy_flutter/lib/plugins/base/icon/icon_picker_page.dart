import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/base/app_bar/app_bar.dart';
import 'package:appflowy/shared/icon_emoji_picker/flowy_icon_emoji_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IconPickerPage extends StatelessWidget {
  const IconPickerPage({
    super.key,
    this.title,
    required this.onSelected,
  });

  final void Function(EmojiPickerResult) onSelected;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlowyAppBar(
        titleText: title ?? LocaleKeys.titleBar_pageIcon.tr(),
      ),
      body: SafeArea(
        child: FlowyIconEmojiPicker(onSelectedEmoji: onSelected),
      ),
    );
  }
}
