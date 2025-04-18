import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/startup/plugin/plugin.dart';
import 'package:appflowy/workspace/presentation/home/home_stack.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pbenum.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flutter/material.dart';

import 'trash_page.dart';

export "./src/sizes.dart";
export "./src/trash_cell.dart";
export "./src/trash_header.dart";

class TrashPluginBuilder extends PluginBuilder {
  @override
  Plugin build(dynamic data) {
    return TrashPlugin(pluginType: pluginType);
  }

  @override
  String get menuName => "TrashPB";

  @override
  FlowySvgData get icon => FlowySvgs.trash_m;

  @override
  PluginType get pluginType => PluginType.trash;

  @override
  ViewLayoutPB get layoutType => ViewLayoutPB.Document;
}

class TrashPluginConfig implements PluginConfig {
  @override
  bool get creatable => false;
}

class TrashPlugin extends Plugin {
  TrashPlugin({required PluginType pluginType}) : _pluginType = pluginType;

  final PluginType _pluginType;

  @override
  PluginWidgetBuilder get widgetBuilder => TrashPluginDisplay();

  @override
  PluginId get id => "TrashStack";

  @override
  PluginType get pluginType => _pluginType;
}

class TrashPluginDisplay extends PluginWidgetBuilder {
  @override
  String? get viewName => LocaleKeys.trash_text.tr();

  @override
  Widget get leftBarItem => FlowyText.medium(LocaleKeys.trash_text.tr());

  @override
  Widget tabBarItem(String pluginId, [bool shortForm = false]) => leftBarItem;

  @override
  Widget? get rightBarItem => null;

  @override
  Widget buildWidget({
    required PluginContext context,
    required bool shrinkWrap,
    Map<String, dynamic>? data,
  }) =>
      const TrashPage(key: ValueKey('TrashPage'));

  @override
  List<NavigationItem> get navigationItems => [this];
}
