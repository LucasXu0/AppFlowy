import 'dart:math';

import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/base/option_color_list.dart';
import 'package:appflowy/mobile/presentation/bottom_sheet/bottom_sheet.dart';
import 'package:appflowy/mobile/presentation/database/card/card_detail/widgets/_field_options.dart';
import 'package:appflowy/mobile/presentation/widgets/widgets.dart';
import 'package:appflowy/plugins/database_view/application/field/type_option/number_format_bloc.dart';
import 'package:appflowy/plugins/database_view/grid/presentation/widgets/header/type_option/date.dart';
import 'package:appflowy/plugins/database_view/widgets/row/cells/select_option_cell/extension.dart';
import 'package:appflowy/util/field_type_extension.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra/uuid.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protobuf/protobuf.dart';

enum FieldOptionMode {
  add,
  edit,
}

class FieldOptionValues {
  FieldOptionValues({
    required this.type,
    required this.name,
    this.dateFormate,
    this.includeTime = false,
    this.timeFormat,
    this.numberFormat,
    this.selectOption = const [],
  });

  FieldType type;
  String name;

  // FieldType.Date
  DateFormatPB? dateFormate;
  bool includeTime;
  TimeFormatPB? timeFormat;

  // FieldType.Num
  NumberFormatPB? numberFormat;

  // FieldType.Select
  // FieldType.MultiSelect
  List<SelectOptionPB> selectOption;

  // FieldType.Checklist
}

class FieldOption extends StatefulWidget {
  const FieldOption({
    super.key,
    required this.mode,
    required this.defaultValues,
  });

  final FieldOptionMode mode;
  final FieldOptionValues defaultValues;

  @override
  State<FieldOption> createState() => _FieldOptionState();
}

class _FieldOptionState extends State<FieldOption> {
  final controller = TextEditingController();

  late FieldOptionValues values;

  @override
  void initState() {
    super.initState();

    values = widget.defaultValues;
    controller.text = values.type.i18n;
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        children: [
          const _Divider(),
          _OptionTextField(
            controller: controller,
            type: values.type,
          ),
          const _Divider(),
          _PropertyType(
            type: values.type,
            onSelected: (type) => setState(
              () {
                controller.text = type.i18n;
                values
                  ..type = type
                  ..name = type.i18n;
              },
            ),
          ),
          const _Divider(),
          ..._buildOption(),
          ..._buildOptionActions(),
        ],
      ),
    );
  }

  List<Widget> _buildOption() {
    switch (values.type) {
      case FieldType.RichText:
        return [
          const _TextOption(),
        ];
      case FieldType.URL:
        return [
          const _URLOption(),
        ];
      case FieldType.Checkbox:
        return [
          const _CheckboxOption(),
        ];
      case FieldType.Number:
        return [
          _NumberOption(
            selectedFormat: values.numberFormat ?? NumberFormatPB.Num,
            onSelected: (format) => setState(
              () => values.numberFormat = format,
            ),
          ),
        ];
      case FieldType.DateTime:
        return [
          _DateOption(
            selectedFormat: values.dateFormate ?? DateFormatPB.Local,
            onSelected: (format) => values.dateFormate = format,
          ),
          const _Divider(),
          _TimeOption(
            includeTime: values.includeTime,
            selectedFormat: values.timeFormat ?? TimeFormatPB.TwelveHour,
            onSelected: (includeTime, format) => values
              ..includeTime = includeTime
              ..timeFormat = format,
          ),
        ];
      case FieldType.SingleSelect:
      case FieldType.MultiSelect:
        return [
          Expanded(
            child: _SelectOption(
              mode: widget.mode,
              selectOption: values.selectOption,
              onAddOptions: (options) {
                if (values.selectOption.lastOrNull?.name.isEmpty == true) {
                  // ignore the add action if the last one doesn't have a name
                  return;
                }
                setState(() {
                  values.selectOption = values.selectOption + options;
                });
              },
              onUpdateOptions: (options) {
                values.selectOption = options;
              },
            ),
          ),
        ];
      default:
        return [];
    }
  }

  List<Widget> _buildOptionActions() {
    return switch (widget.mode) {
      FieldOptionMode.add => [],
      FieldOptionMode.edit => [
          FlowyOptionTile.text(
            text: LocaleKeys.button_delete.tr(),
            leftIcon: const FlowySvg(FlowySvgs.delete_s),
          ),
          FlowyOptionTile.text(
            showTopBorder: false,
            text: LocaleKeys.button_duplicate.tr(),
            leftIcon: const FlowySvg(FlowySvgs.copy_s),
          ),
          FlowyOptionTile.text(
            showTopBorder: false,
            text: LocaleKeys.grid_field_hide.tr(),
            leftIcon: const FlowySvg(FlowySvgs.hide_s),
          ),
        ]
    };
  }
}

class _OptionTextField extends StatelessWidget {
  const _OptionTextField({
    required this.controller,
    required this.type,
  });

  final TextEditingController controller;
  final FieldType type;

  @override
  Widget build(BuildContext context) {
    return FlowyOptionTile.textField(
      controller: controller,
      textFieldPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      leftIcon: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: FlowySvg(
          type.svgData,
          size: const Size.square(36.0),
          blendMode: null,
        ),
      ),
    );
  }
}

class _PropertyType extends StatelessWidget {
  const _PropertyType({
    required this.type,
    required this.onSelected,
  });

  final FieldType type;
  final void Function(FieldType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return FlowyOptionTile.text(
      text: LocaleKeys.grid_field_propertyType.tr(),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlowySvg(
            type.smallSvgData,
          ),
          const HSpace(6.0),
          FlowyText(
            type.i18n,
            color: Theme.of(context).hintColor,
            fontSize: 16.0,
          ),
          const HSpace(4.0),
          FlowySvg(
            FlowySvgs.arrow_right_s,
            color: Theme.of(context).hintColor,
            size: const Size.square(18.0),
          ),
        ],
      ),
      onTap: () {
        showMobileBottomSheet(
          context,
          padding: EdgeInsets.zero,
          builder: (context) {
            return DraggableScrollableSheet(
              expand: false,
              snap: true,
              initialChildSize: 0.7,
              minChildSize: 0.7,
              builder: (context, controller) => FieldOptions(
                scrollController: controller,
                onAddField: (type) {
                  onSelected(type);
                  context.pop();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const VSpace(
      24.0,
    );
  }
}

class _TextOption extends StatelessWidget {
  const _TextOption();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _URLOption extends StatelessWidget {
  const _URLOption();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CheckboxOption extends StatelessWidget {
  const _CheckboxOption();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _DateOption extends StatefulWidget {
  const _DateOption({
    required this.selectedFormat,
    required this.onSelected,
  });

  final DateFormatPB selectedFormat;
  final Function(DateFormatPB format) onSelected;

  @override
  State<_DateOption> createState() => _DateOptionState();
}

class _DateOptionState extends State<_DateOption> {
  DateFormatPB selectedFormat = DateFormatPB.Local;

  @override
  void initState() {
    super.initState();

    selectedFormat = widget.selectedFormat;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 16.0,
          ),
          child: FlowyText(
            LocaleKeys.grid_field_dateFormat.tr(),
            fontSize: 16.0,
            color: Theme.of(context).hintColor,
          ),
        ),
        ...DateFormatPB.values.mapIndexed((index, format) {
          return FlowyOptionTile.checkbox(
            text: format.title(),
            isSelected: selectedFormat == format,
            showTopBorder: index == 0,
            onTap: () {
              widget.onSelected(format);
              setState(() {
                selectedFormat = format;
              });
            },
          );
        }),
      ],
    );
  }
}

class _TimeOption extends StatefulWidget {
  const _TimeOption({
    required this.includeTime,
    required this.selectedFormat,
    required this.onSelected,
  });

  final bool includeTime;
  final TimeFormatPB selectedFormat;
  final Function(bool includeTime, TimeFormatPB format) onSelected;

  @override
  State<_TimeOption> createState() => _TimeOptionState();
}

class _TimeOptionState extends State<_TimeOption> {
  TimeFormatPB selectedFormat = TimeFormatPB.TwelveHour;
  bool includeTime = false;

  @override
  void initState() {
    super.initState();

    selectedFormat = widget.selectedFormat;
    includeTime = widget.includeTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 16.0,
          ),
          child: FlowyText(
            LocaleKeys.grid_field_timeFormat.tr(),
            fontSize: 16.0,
            color: Theme.of(context).hintColor,
          ),
        ),
        FlowyOptionTile.switcher(
          text: LocaleKeys.grid_field_includeTime.tr(),
          isSelected: includeTime,
          onValueChanged: (includeTime) {
            widget.onSelected(includeTime, selectedFormat);
            setState(() {
              this.includeTime = includeTime;
            });
          },
        ),
        if (includeTime)
          ...TimeFormatPB.values.mapIndexed((index, format) {
            return FlowyOptionTile.checkbox(
              text: format.title(),
              isSelected: selectedFormat == format,
              showTopBorder: false,
              onTap: () {
                widget.onSelected(includeTime, format);
                setState(() {
                  selectedFormat = format;
                });
              },
            );
          }),
      ],
    );
  }
}

class _NumberOption extends StatelessWidget {
  const _NumberOption({
    required this.selectedFormat,
    required this.onSelected,
  });

  final NumberFormatPB selectedFormat;
  final void Function(NumberFormatPB format) onSelected;

  @override
  Widget build(BuildContext context) {
    return FlowyOptionTile.text(
      text: LocaleKeys.grid_field_numberFormat.tr(),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlowyText(
            selectedFormat.title(),
            color: Theme.of(context).hintColor,
            fontSize: 16.0,
          ),
          const HSpace(4.0),
          FlowySvg(
            FlowySvgs.arrow_right_s,
            color: Theme.of(context).hintColor,
            size: const Size.square(18.0),
          ),
        ],
      ),
      onTap: () {
        showMobileBottomSheet(
          context,
          padding: EdgeInsets.zero,
          builder: (context) {
            return DraggableScrollableSheet(
              expand: false,
              snap: true,
              initialChildSize: 0.6,
              minChildSize: 0.6,
              builder: (context, scrollController) => _NumberFormatList(
                scrollController: scrollController,
                selectedFormat: selectedFormat,
                onSelected: (type) {
                  onSelected(type);
                  context.pop();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _NumberFormatList extends StatelessWidget {
  const _NumberFormatList({
    this.scrollController,
    required this.selectedFormat,
    required this.onSelected,
  });

  final NumberFormatPB selectedFormat;
  final ScrollController? scrollController;
  final void Function(NumberFormatPB format) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: NumberFormatPB.values
          .mapIndexed(
            (index, element) => FlowyOptionTile.checkbox(
              text: element.title(),
              isSelected: selectedFormat == element,
              showTopBorder: index == 0,
              onTap: () => onSelected(element),
            ),
          )
          .toList(),
    );
  }
}

// single select or multi select
class _SelectOption extends StatelessWidget {
  _SelectOption({
    required this.mode,
    required this.selectOption,
    required this.onAddOptions,
    required this.onUpdateOptions,
  });

  final List<SelectOptionPB> selectOption;
  final void Function(List<SelectOptionPB> options) onAddOptions;
  final void Function(List<SelectOptionPB> options) onUpdateOptions;
  final FieldOptionMode mode;

  final random = Random();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
            horizontal: 16.0,
          ),
          child: FlowyText(
            LocaleKeys.grid_field_optionTitle.tr(),
            fontSize: 16.0,
            color: Theme.of(context).hintColor,
          ),
        ),
        _SelectOptionList(
          selectOptions: selectOption,
          onUpdateOptions: onUpdateOptions,
        ),
        FlowyOptionTile.text(
          text: LocaleKeys.grid_field_addOption.tr(),
          leftIcon: const FlowySvg(FlowySvgs.add_s),
          onTap: () {
            onAddOptions([
              SelectOptionPB(
                id: uuid(),
                name: '',
                color: SelectOptionColorPB.valueOf(
                  random.nextInt(SelectOptionColorPB.values.length),
                ),
              ),
            ]);
          },
        ),
      ],
    );
  }
}

class _SelectOptionList extends StatefulWidget {
  const _SelectOptionList({
    required this.selectOptions,
    required this.onUpdateOptions,
  });

  final List<SelectOptionPB> selectOptions;
  final void Function(List<SelectOptionPB> options) onUpdateOptions;

  @override
  State<_SelectOptionList> createState() => _SelectOptionListState();
}

class _SelectOptionListState extends State<_SelectOptionList> {
  final List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();

    controllers.addAll(
      widget.selectOptions.map((e) => TextEditingController(text: e.name)),
    );
  }

  @override
  void didUpdateWidget(covariant _SelectOptionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final element in controllers) {
      element.dispose();
    }
    controllers.clear();

    controllers.addAll(
      widget.selectOptions.map((e) => TextEditingController(text: e.name)),
    );
  }

  @override
  void dispose() {
    for (final element in controllers) {
      element.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectOptions.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: widget.selectOptions
          .mapIndexed(
            (index, option) => FlowyOptionTile.textField(
              controller: controllers[index],
              textFieldHintText: LocaleKeys.grid_field_typeANewOption.tr(),
              showTopBorder: index == 0,
              showBottomBorder: index != widget.selectOptions.length - 1,
              textFieldPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              trailing: _SelectOptionColor(
                color: option.color,
                onChanged: (color) {
                  _updateOption(index, null, color);
                  context.pop();
                },
              ),
              onTextChanged: (name) {
                _updateOption(index, name, null);
              },
            ),
          )
          .toList(),
    );
  }

  void _updateOption(int index, String? name, SelectOptionColorPB? color) {
    final options = [...widget.selectOptions];
    final option = options[index];
    option.freeze();
    options[index] = option.rebuild((p0) {
      if (name != null) p0.name = name;
      if (color != null) p0.color = color;
    });
    widget.onUpdateOptions(options);
  }
}

class _SelectOptionTile extends StatefulWidget {
  const _SelectOptionTile();

  @override
  State<_SelectOptionTile> createState() => __SelectOptionTileState();
}

class __SelectOptionTileState extends State<_SelectOptionTile> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowyOptionTile.textField(
      controller: controllers,
      textFieldHintText: LocaleKeys.grid_field_typeANewOption.tr(),
      showTopBorder: index == 0,
      showBottomBorder: index != widget.selectOptions.length - 1,
      textFieldPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      trailing: _SelectOptionColor(
        color: option.color,
        onChanged: (color) {
          _updateOption(index, null, color);
          context.pop();
        },
      ),
      onTextChanged: (name) {
        _updateOption(index, name, null);
      },
    );
  }
}

class _SelectOptionColor extends StatelessWidget {
  const _SelectOptionColor({
    required this.color,
    required this.onChanged,
  });

  final SelectOptionColorPB color;
  final void Function(SelectOptionColorPB) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMobileBottomSheet(
          context,
          showHeader: true,
          showCloseButton: true,
          title: LocaleKeys.grid_selectOption_colorPanelTitle.tr(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          builder: (context) {
            return OptionColorList(
              selectedColor: color,
              onSelectedColor: onChanged,
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.toColor(context),
          borderRadius: Corners.s10Border,
        ),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: const FlowySvg(
          FlowySvgs.arrow_down_s,
          size: Size.square(20),
        ),
      ),
    );
  }
}
