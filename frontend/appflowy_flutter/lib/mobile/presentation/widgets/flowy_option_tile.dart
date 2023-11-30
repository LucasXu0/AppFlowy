import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';

enum FlowyOptionTileType {
  text,
  textField,
  checkbox,
}

// used in cell editor

class FlowyOptionTile extends StatelessWidget {
  const FlowyOptionTile._({
    required this.type,
    this.showTopBorder = true,
    this.showBottomBorder = true,
    this.text,
    this.controller,
    this.leading,
    this.onTap,
    this.trailing,
    this.textFieldPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
    ),
    this.isSelected = false,
    this.onValueChanged,
  });

  factory FlowyOptionTile.text({
    required String text,
    bool showTopBorder = true,
    bool showBottomBorder = true,
    Widget? leftIcon,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    return FlowyOptionTile._(
      type: FlowyOptionTileType.text,
      text: text,
      controller: null,
      onTap: onTap,
      showTopBorder: showTopBorder,
      showBottomBorder: showBottomBorder,
      leading: leftIcon,
      trailing: leading,
    );
  }

  factory FlowyOptionTile.textField({
    required TextEditingController controller,
    EdgeInsets textFieldPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
    ),
    bool showTopBorder = true,
    bool showBottomBorder = true,
    Widget? leftIcon,
    Widget? leading,
  }) {
    return FlowyOptionTile._(
      type: FlowyOptionTileType.text,
      controller: controller,
      textFieldPadding: textFieldPadding,
      text: null,
      onTap: null,
      showTopBorder: showTopBorder,
      showBottomBorder: showBottomBorder,
      leading: leftIcon,
      trailing: leading,
    );
  }

  factory FlowyOptionTile.checkbox({
    required String text,
    required bool isSelected,
    required VoidCallback? onTap,
    bool showTopBorder = true,
    bool showBottomBorder = true,
  }) {
    return FlowyOptionTile._(
      type: FlowyOptionTileType.checkbox,
      isSelected: isSelected,
      text: text,
      onTap: onTap,
      showTopBorder: showTopBorder,
      showBottomBorder: showBottomBorder,
      trailing: isSelected
          ? const FlowySvg(
              FlowySvgs.check_s,
              size: Size.square(24.0),
            )
          : null,
    );
  }

  factory FlowyOptionTile.switcher({
    required String text,
    required bool isSelected,
    required void Function(bool value) onValueChanged,
    bool showTopBorder = true,
    bool showBottomBorder = true,
    Widget? leftIcon,
  }) {
    return FlowyOptionTile._(
      type: FlowyOptionTileType.text,
      text: text,
      controller: null,
      onTap: null,
      showTopBorder: showTopBorder,
      showBottomBorder: showBottomBorder,
      leading: leftIcon,
      trailing: _Switcher(value: isSelected, onChanged: onValueChanged),
    );
  }

  final bool showTopBorder;
  final bool showBottomBorder;
  final String? text;
  final TextEditingController? controller;
  final EdgeInsets textFieldPadding;
  final void Function()? onTap;
  final Widget? leading;
  final Widget? trailing;

  // only used in checkbox or switcher
  final bool isSelected;

  // only used in switcher
  final void Function(bool value)? onValueChanged;

  final FlowyOptionTileType type;

  @override
  Widget build(BuildContext context) {
    final child = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: FlowyOptionDecorateBox(
        showTopBorder: showTopBorder,
        showBottomBorder: showBottomBorder,
        child: Row(
          children: [
            _buildText(),
            ..._buildTextField(),
            const Spacer(),
            trailing ?? const SizedBox.shrink(),
            const HSpace(12.0),
          ],
        ),
      ),
    );

    if (type == FlowyOptionTileType.checkbox) {
      return FlowyButton(
        expandText: true,
        margin: EdgeInsets.zero,
        onTap: onTap,
        text: child,
      );
    }

    return child;
  }

  Widget _buildText() {
    if (text == null) {
      return const SizedBox.shrink();
    }

    switch (type) {
      case FlowyOptionTileType.text:
        return FlowyButton(
          useIntrinsicWidth: true,
          text: FlowyText(
            text!,
            fontSize: 16.0,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          leftIcon: leading,
          leftIconSize: const Size.square(24.0),
          iconPadding: 8.0,
          onTap: onTap,
        );
      case FlowyOptionTileType.textField:
        return const SizedBox.shrink();
      case FlowyOptionTileType.checkbox:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: FlowyText(
            text!,
            fontSize: 16.0,
          ),
        );
    }
  }

  List<Widget> _buildTextField() {
    if (controller == null) {
      return [
        const SizedBox.shrink(),
      ];
    }

    return [
      if (leading != null) leading!,
      Expanded(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(height: 52.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: textFieldPadding,
            ),
            onChanged: (value) {},
            onSubmitted: (value) {},
          ),
        ),
      ),
    ];
  }
}

class _Switcher extends StatelessWidget {
  const _Switcher({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch.adaptive(
          value: value,
          activeColor: const Color(0xFF00BCF0),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
