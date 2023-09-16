import 'package:appflowy/workspace/application/panes/panes.dart';
import 'package:appflowy/workspace/application/tabs/tabs.dart';
import 'package:appflowy/workspace/presentation/home/home_stack.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';

enum CrossDraggableType { view, tab, pane, none }

class CrossDraggablesEntity {
  late final dynamic draggable;
  late final CrossDraggableType crossDraggableType;

  CrossDraggablesEntity({
    required dynamic draggable,
  }) {
    if (draggable is ViewPB) {
      this.draggable = draggable;
      crossDraggableType = CrossDraggableType.view;
    } else if (draggable is PaneNode) {
      this.draggable = draggable;
      crossDraggableType = CrossDraggableType.pane;
    } else if (draggable is (Tabs, PageManager)) {
      this.draggable = draggable;
      crossDraggableType = CrossDraggableType.tab;
    } else {
      this.draggable = null;
      crossDraggableType = CrossDraggableType.none;
    }
  }
}
