import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './node.dart';

// constant number: 2^53 - 1
const int _maxInt = 9007199254740991;

class TextOperation {
  bool get isEmpty {
    return length == 0;
  }

  int get length {
    return 0;
  }

  Attributes? get attributes {
    return null;
  }
}

int _hashAttributes(Attributes attributes) {
  return Object.hashAllUnordered(
    attributes.entries.map(
      (e) => Object.hash(e.key, e.value),
    ),
  );
}

class TextInsert extends TextOperation {
  String content;
  final Attributes? _attributes;

  TextInsert(this.content, [Attributes? attrs]) : _attributes = attrs;

  @override
  int get length {
    return content.length;
  }

  @override
  Attributes? get attributes {
    return _attributes;
  }

  @override
  bool operator ==(Object other) {
    if (other is! TextInsert) {
      return false;
    }
    return content == other.content &&
        mapEquals(_attributes, other._attributes);
  }

  @override
  int get hashCode {
    final contentHash = content.hashCode;
    final attrs = _attributes;
    return Object.hash(
        contentHash, attrs == null ? null : _hashAttributes(attrs));
  }
}

class TextRetain extends TextOperation {
  int _length;
  final Attributes? _attributes;

  TextRetain({
    required length,
    attributes,
  })  : _length = length,
        _attributes = attributes;

  @override
  bool get isEmpty {
    return length == 0;
  }

  @override
  int get length {
    return _length;
  }

  set length(int v) {
    _length = v;
  }

  @override
  Attributes? get attributes {
    return _attributes;
  }

  @override
  bool operator ==(Object other) {
    if (other is! TextRetain) {
      return false;
    }
    return _length == other.length && mapEquals(_attributes, other._attributes);
  }

  @override
  int get hashCode {
    final attrs = _attributes;
    return Object.hash(_length, attrs == null ? null : _hashAttributes(attrs));
  }
}

class TextDelete extends TextOperation {
  int _length;

  TextDelete({
    required int length,
  }) : _length = length;

  @override
  bool get isEmpty {
    return length == 0;
  }

  @override
  int get length {
    return _length;
  }

  set length(int v) {
    _length = v;
  }

  @override
  bool operator ==(Object other) {
    if (other is! TextDelete) {
      return false;
    }
    return _length == other.length;
  }

  @override
  int get hashCode {
    return _length.hashCode;
  }
}

class _OpIterator {
  final UnmodifiableListView<TextOperation> _operations;
  int _index = 0;
  int _offset = 0;

  _OpIterator(List<TextOperation> operations)
      : _operations = UnmodifiableListView(operations);

  bool get hasNext {
    return peekLength() < _maxInt;
  }

  TextOperation? peek() {
    if (_index >= _operations.length) {
      return null;
    }

    return _operations[_index];
  }

  int peekLength() {
    if (_index < _operations.length) {
      final op = _operations[_index];
      return op.length - _offset;
    }
    return _maxInt;
  }

  TextOperation next([int? length]) {
    length ??= _maxInt;

    if (_index >= _operations.length) {
      return TextRetain(length: _maxInt);
    }

    final nextOp = _operations[_index];

    final offset = _offset;
    final opLength = nextOp.length;
    if (length >= opLength - offset) {
      length = opLength - offset;
      _index += 1;
      _offset = 0;
    } else {
      _offset += length;
    }
    if (nextOp is TextDelete) {
      return TextDelete(
        length: length,
      );
    }

    if (nextOp is TextRetain) {
      return TextRetain(
        length: length,
        attributes: nextOp.attributes,
      );
    }

    if (nextOp is TextInsert) {
      return TextInsert(
        nextOp.content.substring(offset, offset + length),
        nextOp.attributes,
      );
    }

    return TextRetain(length: _maxInt);
  }

  List<TextOperation> rest() {
    if (!hasNext) {
      return [];
    } else if (_offset == 0) {
      return _operations.sublist(_index);
    } else {
      final offset = _offset;
      final index = _index;
      final _next = next();
      final rest = _operations.sublist(_index);
      _offset = offset;
      _index = index;
      return [_next] + rest;
    }
  }
}

// basically copy from: https://github.com/quilljs/delta
class Delta {
  final List<TextOperation> operations;

  Delta([List<TextOperation>? ops]) : operations = ops ?? <TextOperation>[];

  Delta add(TextOperation textOp) {
    if (textOp.isEmpty) {
      return this;
    }

    if (operations.isNotEmpty) {
      final lastOp = operations.last;
      if (lastOp is TextDelete && textOp is TextDelete) {
        lastOp.length += textOp.length;
        return this;
      }
      if (mapEquals(lastOp.attributes, textOp.attributes)) {
        if (lastOp is TextInsert && textOp is TextInsert) {
          lastOp.content += textOp.content;
          return this;
        }
        // if there is an delete before the insert
        // swap the order
        if (lastOp is TextDelete && textOp is TextInsert) {
          operations.removeLast();
          operations.add(textOp);
          operations.add(lastOp);
          return this;
        }
        if (lastOp is TextRetain && textOp is TextRetain) {
          lastOp.length += textOp.length;
          return this;
        }
      }
    }

    operations.add(textOp);
    return this;
  }

  Delta slice(int start, [int? end]) {
    final result = Delta();
    final iterator = _OpIterator(operations);
    int index = 0;

    while ((end == null || index < end) && iterator.hasNext) {
      TextOperation? nextOp;
      if (index < start) {
        nextOp = iterator.next(start - index);
      } else {
        nextOp = iterator.next(end == null ? null : end - index);
        result.add(nextOp);
      }

      index += nextOp.length;
    }

    return result;
  }

  Delta insert(String content, [Attributes? attributes]) {
    final op = TextInsert(content, attributes);
    return add(op);
  }

  Delta retain(int length, [Attributes? attributes]) {
    final op = TextRetain(length: length, attributes: attributes);
    return add(op);
  }

  Delta delete(int length) {
    final op = TextDelete(length: length);
    return add(op);
  }

  int get length {
    return operations.fold(
        0, (previousValue, element) => previousValue + element.length);
  }

  Delta compose(Delta other) {
    final thisIter = _OpIterator(operations);
    final otherIter = _OpIterator(other.operations);
    final ops = <TextOperation>[];

    final firstOther = otherIter.peek();
    if (firstOther != null &&
        firstOther is TextRetain &&
        firstOther.attributes == null) {
      int firstLeft = firstOther.length;
      while (
          thisIter.peek() is TextInsert && thisIter.peekLength() <= firstLeft) {
        firstLeft -= thisIter.peekLength();
        final next = thisIter.next();
        ops.add(next);
      }
      if (firstOther.length - firstLeft > 0) {
        otherIter.next(firstOther.length - firstLeft);
      }
    }

    final delta = Delta(ops);
    while (thisIter.hasNext || otherIter.hasNext) {
      if (otherIter.peek() is TextInsert) {
        final next = otherIter.next();
        delta.add(next);
      } else if (thisIter.peek() is TextDelete) {
        final next = thisIter.next();
        delta.add(next);
      } else {
        // otherIs
        final length = min(thisIter.peekLength(), otherIter.peekLength());
        final thisOp = thisIter.next(length);
        final otherOp = otherIter.next(length);
        final attributes = _composeMap(thisOp.attributes, otherOp.attributes);
        if (otherOp is TextRetain && otherOp.length > 0) {
          TextOperation? newOp;
          if (thisOp is TextRetain) {
            newOp = TextRetain(length: length, attributes: attributes);
          } else if (thisOp is TextInsert) {
            newOp = TextInsert(thisOp.content, attributes);
          }

          if (newOp != null) {
            delta.add(newOp);
          }

          // Optimization if rest of other is just retain
          if (!otherIter.hasNext &&
              delta.operations[delta.operations.length - 1] == newOp) {
            final rest = Delta(thisIter.rest());
            return delta.concat(rest).chop();
          }
        } else if (otherOp is TextDelete && (thisOp is TextRetain)) {
          delta.add(otherOp);
        }
      }
    }

    return delta.chop();
  }

  Delta concat(Delta other) {
    var ops = [...operations];
    if (other.operations.isNotEmpty) {
      ops.add(other.operations[0]);
      ops.addAll(other.operations.sublist(1));
    }
    return Delta(ops);
  }

  Delta chop() {
    if (operations.isEmpty) {
      return this;
    }
    final lastOp = operations.last;
    if (lastOp is TextRetain && (lastOp.attributes?.length ?? 0) == 0) {
      operations.removeLast();
    }
    return this;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Delta) {
      return false;
    }
    return listEquals(operations, other.operations);
  }

  @override
  int get hashCode {
    return hashList(operations);
  }
}

Attributes? _composeMap(Attributes? a, Attributes? b) {
  a ??= {};
  b ??= {};
  final Attributes attributes = {};
  attributes.addAll(b);

  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) {
      attributes[entry.key] = entry.value;
    }
  }

  if (attributes.isEmpty) {
    return null;
  }

  return attributes;
}
