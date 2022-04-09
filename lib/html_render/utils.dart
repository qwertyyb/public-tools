import 'dart:collection';

import 'package:flutter/material.dart';

final colors = {
  'red': Colors.red,
  'white': Colors.white,
  'black54': Colors.black54
};

final mainAxisAlignment = {
  'center': MainAxisAlignment.center,
  'start': MainAxisAlignment.start,
  'end': MainAxisAlignment.end,
  'spaceAround': MainAxisAlignment.spaceAround,
  'spaceBetween': MainAxisAlignment.spaceBetween,
  'spaceEvenly': MainAxisAlignment.spaceEvenly
};
final crossAxisAlignment = {
  'center': CrossAxisAlignment.center,
  'start': CrossAxisAlignment.start,
  'end': CrossAxisAlignment.end,
  'baseline': CrossAxisAlignment.baseline,
  'stretch': CrossAxisAlignment.stretch,
};
final fontWeight = {
  'normal': FontWeight.normal,
  'bold': FontWeight.bold,
  '100': FontWeight.w100,
  '200': FontWeight.w200,
  '300': FontWeight.w300,
  '400': FontWeight.w400,
  '500': FontWeight.w500,
  '600': FontWeight.w600,
  '700': FontWeight.w700,
  '800': FontWeight.w800,
  '900': FontWeight.w900
};

final icons = {
  'download': Icons.download,
  'delete': Icons.delete,
  'downloading': Icons.downloading
};

final scrollDirection = {
  'vertical': Axis.horizontal,
  'horizontal': Axis.horizontal
};

T? parseAttr<T>(LinkedHashMap<Object, String> attributes, String attrName,
    T? defaultValue, Map<String, T> def) {
  final value = attributes[attrName];
  if (value == null) return defaultValue;
  if (def.keys.contains(value)) {
    return def[value];
  }
  return defaultValue;
}

double attr2double(LinkedHashMap<Object, String> attributes, String attrName) {
  return attributes[attrName] != null ? double.parse(attributes[attrName]!) : 0;
}

enum Direction { top, left, right, bottom }

Map<Direction, double> parseDirection(
    LinkedHashMap<Object, String> attributes, String attrName) {
  final value = attributes[attrName];
  Map<Direction, double> result = {
    Direction.top: 0,
    Direction.bottom: 0,
    Direction.left: 0,
    Direction.right: 0,
  };
  if (value == null) return result;
  final arr = value.split(" ");
  if (arr.length == 1) {
    final distance = double.parse(arr[0]);
    result.forEach((key, value) {
      result[key] = distance;
    });
  } else if (arr.length == 2) {
    // 竖向 + 横向
    result[Direction.top] = double.parse(arr[0]);
    result[Direction.bottom] = double.parse(arr[0]);
    result[Direction.left] = double.parse(arr[1]);
    result[Direction.right] = double.parse(arr[1]);
  } else if (arr.length == 4) {
    result[Direction.top] = double.parse(arr[0]);
    result[Direction.right] = double.parse(arr[1]);
    result[Direction.bottom] = double.parse(arr[2]);
    result[Direction.left] = double.parse(arr[3]);
  }
  return result;
}

Widget getFirstWidget(List<Widget> widgets) {
  return widgets.isEmpty ? Text('no child') : widgets.first;
}

Map<String, dynamic> createEventData(LinkedHashMap<Object, String> attributes) {
  LinkedHashMap args = LinkedHashMap<Object, String>.from(attributes);
  args.removeWhere((key, value) {
    if (key is String) {
      return !(key).startsWith('data-');
    }
    return true;
  });

  final dataset = args.map((key, value) =>
      MapEntry((key as String).substring('data-'.length), value));
  return {
    'target': {'dataset': dataset}
  };
}
