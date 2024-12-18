import 'package:appflowy/plugins/base/emoji/emoji_picker_screen.dart';
import 'package:appflowy/shared/icon_emoji_picker/flowy_icon_emoji_picker.dart';
import 'package:appflowy/workspace/presentation/settings/widgets/emoji_picker/emoji_picker.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

class EmojiPickerButton extends StatelessWidget {
  EmojiPickerButton({
    super.key,
    required this.emoji,
    required this.onSubmitted,
    this.emojiPickerSize = const Size(360, 380),
    this.emojiSize = 18.0,
    this.defaultIcon,
    this.offset,
    this.direction,
    this.title,
    this.showBorder = true,
    this.enable = true,
    this.margin,
    this.buttonSize,
  });

  final String emoji;
  final double emojiSize;
  final Size emojiPickerSize;
  final void Function(String emoji, PopoverController? controller) onSubmitted;
  final PopoverController popoverController = PopoverController();
  final Widget? defaultIcon;
  final Offset? offset;
  final PopoverDirection? direction;
  final String? title;
  final bool showBorder;
  final bool enable;
  final EdgeInsets? margin;
  final Size? buttonSize;

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isDesktopOrWeb) {
      return _DesktopEmojiPickerButton(
        emoji: emoji,
        onSubmitted: onSubmitted,
        emojiPickerSize: emojiPickerSize,
        emojiSize: emojiSize,
        defaultIcon: defaultIcon,
        offset: offset,
        direction: direction,
        title: title,
        showBorder: showBorder,
        enable: enable,
        buttonSize: buttonSize,
      );
    }

    return _MobileEmojiPickerButton(
      emoji: emoji,
      onSubmitted: onSubmitted,
      emojiSize: emojiSize,
      enable: enable,
      title: title,
      margin: margin,
    );
  }
}

class _DesktopEmojiPickerButton extends StatelessWidget {
  _DesktopEmojiPickerButton({
    required this.emoji,
    required this.onSubmitted,
    this.emojiPickerSize = const Size(360, 380),
    this.emojiSize = 18.0,
    this.defaultIcon,
    this.offset,
    this.direction,
    this.title,
    this.showBorder = true,
    this.enable = true,
    this.buttonSize,
  });

  final String emoji;
  final double emojiSize;
  final Size emojiPickerSize;
  final void Function(String emoji, PopoverController? controller) onSubmitted;
  final PopoverController popoverController = PopoverController();
  final Widget? defaultIcon;
  final Offset? offset;
  final PopoverDirection? direction;
  final String? title;
  final bool showBorder;
  final bool enable;
  final Size? buttonSize;
  @override
  Widget build(BuildContext context) {
    return AppFlowyPopover(
      controller: popoverController,
      constraints: BoxConstraints.expand(
        width: emojiPickerSize.width,
        height: emojiPickerSize.height,
      ),
      offset: offset,
      margin: EdgeInsets.zero,
      direction: direction ?? PopoverDirection.rightWithTopAligned,
      popupBuilder: (_) => Container(
        width: emojiPickerSize.width,
        height: emojiPickerSize.height,
        padding: const EdgeInsets.all(4.0),
        child: EmojiSelectionMenu(
          onSubmitted: (emoji) => onSubmitted(emoji, popoverController),
          onExit: () {},
        ),
      ),
      child: Container(
        width: buttonSize?.width ?? 30.0,
        height: buttonSize?.height ?? 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: showBorder
              ? Border.all(
                  color: Theme.of(context).dividerColor,
                )
              : null,
        ),
        child: FlowyButton(
          margin: emoji.isEmpty && defaultIcon != null
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 2.0),
          expandText: false,
          text: emoji.isEmpty && defaultIcon != null
              ? defaultIcon!
              : FlowyText.emoji(emoji, fontSize: emojiSize),
          onTap: enable ? popoverController.show : null,
        ),
      ),
    );
  }
}

class _MobileEmojiPickerButton extends StatelessWidget {
  const _MobileEmojiPickerButton({
    required this.emoji,
    required this.onSubmitted,
    this.emojiSize = 18.0,
    this.enable = true,
    this.title,
    this.margin,
  });

  final String emoji;
  final double emojiSize;
  final void Function(String emoji, PopoverController? controller) onSubmitted;
  final String? title;
  final bool enable;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FlowyButton(
      useIntrinsicWidth: true,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      text: FlowyText.emoji(
        emoji,
        fontSize: emojiSize,
        optimizeEmojiAlign: true,
      ),
      onTap: enable
          ? () async {
              final result = await context.push<EmojiPickerResult>(
                Uri(
                  path: MobileEmojiPickerScreen.routeName,
                  queryParameters: {MobileEmojiPickerScreen.pageTitle: title},
                ).toString(),
              );
              if (result != null) {
                onSubmitted(result.emoji, null);
              }
            }
          : null,
    );
  }
}
