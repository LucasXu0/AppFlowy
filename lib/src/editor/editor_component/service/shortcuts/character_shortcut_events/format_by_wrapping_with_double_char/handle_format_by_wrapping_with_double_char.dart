import 'package:appflowy_editor/appflowy_editor.dart';

// We currently have only one format style is triggered by double characters.
// **abc** or __abc__ -> bold abc
// If we have more in the future, we should add them in this enum and update the [style] variable in [handleDoubleCharactersFormat].
enum DoubleCharacterFormatStyle {
  bold,
}

bool handleFormatByWrappingWithDoubleChar({
  // for demonstration purpose, the following comments use * to represent the character from the parameter [char].
  required EditorState editorState,
  required String char,
  required DoubleCharacterFormatStyle formatStyle,
}) {
  assert(char.length == 1);
  final selection = editorState.selection;
  // if the selection is not collapsed,
  // we should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // if the node doesn't contain the delta(which means it isn't a text),
  // we don't need to format it.
  if (node == null || delta == null) {
    return false;
  }

  final plainText = delta.toPlainText();

  // The plainText should look like **abc*, the last char in the plainText should be *[char]. Otherwise, we don't need to format it.
  if (plainText.length < 2 || plainText[selection.end.offset - 1] != char) {
    return false;
  }

  // find all the index of *[char]
  final charIndexList = <int>[];
  for (var i = 0; i < plainText.length; i++) {
    if (plainText[i] == char) {
      charIndexList.add(i);
    }
  }
  if (charIndexList.length < 3) {
    return false;
  }

  // for example: **abc* -> [0, 1, 5]
  // thirdLastCharIndex = 0, secondLastCharIndex = 1, lastCharIndex = 5
  // make sure the third *[char] and second *[char] are connected
  // make sure the second *[char] and last *[char] are split by at least one character
  final thirdLastCharIndex = charIndexList[charIndexList.length - 3];
  final secondLastCharIndex = charIndexList[charIndexList.length - 2];
  final lastCharIndex = charIndexList[charIndexList.length - 1];
  if (secondLastCharIndex != thirdLastCharIndex + 1 ||
      lastCharIndex == secondLastCharIndex + 1) {
    return false;
  }

  // if all the conditions are met, we should format the text.
  // 1. delete all the *[char]
  // 2. update the style of the text surrounded by the double *[char] to [formatStyle]
  // 3. update the cursor position.
  final deletion = editorState.transaction
    ..deleteText(node, lastCharIndex, 1)
    ..deleteText(node, thirdLastCharIndex, 2);
  editorState.apply(deletion);

  // To minimize errors, retrieve the format style from an enum that is specific to double characters.
  final String style;

  switch (formatStyle) {
    case DoubleCharacterFormatStyle.bold:
      style = 'bold';
      break;
    default:
      style = '';
      assert(false, 'Invalid format style');
  }

  final format = editorState.transaction
    ..formatText(
      node,
      thirdLastCharIndex,
      selection.end.offset - thirdLastCharIndex - 3,
      {
        style: true,
      },
    )
    ..afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: selection.end.offset - 3,
      ),
    );
  editorState.apply(format);
  return true;
}
