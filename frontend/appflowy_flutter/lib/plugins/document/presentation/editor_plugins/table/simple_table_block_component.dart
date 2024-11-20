import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_constants.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/simple_table_row_block_component.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef SimpleTableColumnWidths = Map<String, double>;

class SimpleTableBlockKeys {
  const SimpleTableBlockKeys._();

  static const String type = 'simple_table';

  // enable header row
  // it's a bool value, default is false
  static const String enableHeaderRow = 'enable_header_row';

  // enable column header
  // it's a bool value, default is false
  static const String enableColumnHeader = 'enable_column_header';

  // column colors
  // it's a list of color strings
  // the number of colors should be the same as the number of columns
  static const String columnColors = 'column_colors';

  // row colors
  // it's a list of color strings
  // the number of colors should be the same as the number of rows
  static const String rowColors = 'row_colors';

  // column alignments
  // it's a list of align strings
  // the value should be one of the following: 'left', 'center', 'right'
  // the number of aligns should be the same as the number of columns
  static const String columnAligns = 'column_aligns';

  // row alignments
  // it's a list of align strings
  // the value should be one of the following: 'top', 'center', 'bottom'
  // the number of aligns should be the same as the number of rows
  static const String rowAligns = 'row_aligns';

  // column widths
  // it's a `SimpleTableColumnWidths` value, {column_index: width, ...}

  static const String columnWidths = 'column_widths';
}

Node simpleTableBlockNode({
  bool enableHeaderRow = false,
  bool enableColumnHeader = false,
  Map<int, String>? columnColors,
  Map<int, String>? rowColors,
  Map<int, String>? columnAligns,
  Map<int, String>? rowAligns,
  SimpleTableColumnWidths? columnWidths,
  required List<Node> children,
}) {
  assert(children.every((e) => e.type == SimpleTableRowBlockKeys.type));

  // if the column widths is not provided, we will use the default value 100
  columnWidths ??= Map.fromEntries(
    Iterable.generate(
      children.first.children.length,
      (index) =>
          MapEntry(index.toString(), SimpleTableConstants.defaultColumnWidth),
    ),
  );

  return Node(
    type: SimpleTableBlockKeys.type,
    attributes: {
      SimpleTableBlockKeys.enableHeaderRow: enableHeaderRow,
      SimpleTableBlockKeys.enableColumnHeader: enableColumnHeader,
      SimpleTableBlockKeys.columnColors: columnColors,
      SimpleTableBlockKeys.rowColors: rowColors,
      SimpleTableBlockKeys.columnAligns: columnAligns,
      SimpleTableBlockKeys.rowAligns: rowAligns,
      SimpleTableBlockKeys.columnWidths: columnWidths,
    },
    children: children,
  );
}

class SimpleTableBlockComponentBuilder extends BlockComponentBuilder {
  SimpleTableBlockComponentBuilder({
    super.configuration,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return SimpleTableBlockWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  BlockComponentValidate get validate => (node) => node.children.isNotEmpty;
}

class SimpleTableBlockWidget extends BlockComponentStatefulWidget {
  const SimpleTableBlockWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<SimpleTableBlockWidget> createState() => _SimpleTableBlockWidgetState();
}

class _SimpleTableBlockWidgetState extends State<SimpleTableBlockWidget>
    with
        SelectableMixin,
        BlockComponentConfigurable,
        BlockComponentTextDirectionMixin,
        BlockComponentBackgroundColorMixin {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  late EditorState editorState = context.read<EditorState>();

  final tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // IntrinsicWidth and IntrinsicHeight are used to make the table size fit the content.
    Widget child = IntrinsicWidth(
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildRows(),
        ),
      ),
    );

    child = Padding(
      padding: padding,
      child: child,
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      remoteSelection: editorState.remoteSelections,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }

  List<Widget> _buildRows() {
    final List<Widget> rows = [];
    rows.add(
      const Divider(
        color: SimpleTableConstants.borderColor,
        height: 1,
      ),
    );
    for (final child in node.children) {
      rows.add(editorState.renderer.build(context, child));
      rows.add(
        const Divider(
          color: SimpleTableConstants.borderColor,
          height: 1,
        ),
      );
    }
    return rows;
  }

  RenderBox get _renderBox => context.findRenderObject() as RenderBox;

  @override
  Position start() => Position(path: widget.node.path);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    final parentBox = context.findRenderObject();
    final tableBox = tableKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && tableBox is RenderBox) {
      return [
        (shiftWithBaseOffset
                ? tableBox.localToGlobal(Offset.zero, ancestor: parentBox)
                : Offset.zero) &
            tableBox.size,
      ];
    }
    return [Offset.zero & _renderBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) =>
      _renderBox.localToGlobal(offset);

  @override
  Rect getBlockRect({
    bool shiftWithBaseOffset = false,
  }) {
    return getRectsInSelection(Selection.invalid()).first;
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    final size = _renderBox.size;
    return Rect.fromLTWH(-size.width / 2.0, 0, size.width, size.height);
  }
}
