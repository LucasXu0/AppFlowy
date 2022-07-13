import 'package:flowy_editor/flowy_editor.dart';
import 'package:flutter/material.dart';

class TextWithCheckBoxNodeBuilder extends NodeWidgetBuilder {
  TextWithCheckBoxNodeBuilder.create({
    required super.node,
    required super.editorState,
  }) : super.create();

  // TODO: check the type
  bool get isCompleted => node.attributes['checkbox'] as bool;

  @override
  Widget build(BuildContext buildContext) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: isCompleted, onChanged: (value) {}),
        Expanded(
          child: renderPlugins.buildWidget(
            context: NodeWidgetContext(
              buildContext: buildContext,
              node: node,
              editorState: editorState,
            ),
            withSubtype: false,
          ),
        )
      ],
    );
  }
}
