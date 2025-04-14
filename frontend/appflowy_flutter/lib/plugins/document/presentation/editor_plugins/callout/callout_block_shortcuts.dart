import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Pressing Enter in a callout block will insert a newline (\n) within the callout,
/// while pressing Shift+Enter in a callout will insert a new paragraph next to the callout.
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent insertNewLineInCalloutBlock =
    CharacterShortcutEvent(
  key: 'insert a new line in callout block',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.type != CalloutBlockKeys.type) {
    return false;
  }

  // delete the selection
  await editorState.deleteSelection(selection);

  if (HardwareKeyboard.instance.isShiftPressed) {
    // ignore the shift+enter event, fallback to the default behavior
    return false;
  } else if (node.children.isEmpty) {
    // insert a new paragraph within the callout block
    final path = node.path.child(0);
    final transaction = editorState.transaction;
    transaction.insertNode(
      path,
      paragraphNode(),
    );
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
      ),
    );
    await editorState.apply(transaction);
  }

  return true;
};

final CommandShortcutEvent backspaceInCalloutBlock = CommandShortcutEvent(
  key: 'backspace in callout block',
  getDescription: () => 'Backspace in callout block',
  command: 'backspace',
  handler: _backspaceHandler,
);

CommandShortcutEventHandler _backspaceHandler = (editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null ||
      !selection.isCollapsed ||
      selection.startIndex != 0) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return KeyEventResult.ignored;
  }

  // check if the node is in a callout block
  final callOutParent =
      node.findParent((node) => node.type == CalloutBlockKeys.type);
  if (callOutParent == null) {
    return KeyEventResult.ignored;
  }

  // check if the callout block has only one child
  final children = callOutParent.children;
  if (children.length != 1) {
    return KeyEventResult.ignored;
  }

  final child = children.first;
  // only delete the callout block if the child is a paragraph block and the paragraph block is empty
  if (child.type != ParagraphBlockKeys.type || child.delta?.isEmpty != true) {
    return KeyEventResult.ignored;
  }

  // delete the first paragraph block and move the cursor to the end of the callout block
  final transaction = editorState.transaction;
  transaction.deleteNode(child);
  transaction.afterSelection = Selection.collapsed(
    Position(
      path: callOutParent.path,
      offset: callOutParent.delta?.length ?? 0,
    ),
  );
  editorState.apply(transaction);

  return KeyEventResult.skipRemainingHandlers;
};
