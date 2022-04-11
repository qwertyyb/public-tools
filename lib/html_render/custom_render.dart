import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../utils/logger.dart';
import 'utils.dart';

typedef void InvokeDomEvent(String handlerName, Map<String, dynamic> eventData);
typedef Widget WidgetRender(
  dom.Element element,
  InvokeDomEvent invokeEvent,
);

WidgetRender renderRow = (element, invokeEvent) {
  return Row(
    mainAxisAlignment: parseAttr(
      element.attributes,
      'mainaxisalignment',
      MainAxisAlignment.start,
      mainAxisAlignment,
    )!,
    crossAxisAlignment: parseAttr(
      element.attributes,
      'crossaxisalignment',
      CrossAxisAlignment.center,
      crossAxisAlignment,
    )!,
    children: renderNodes(element.nodes, invokeEvent),
  );
};

WidgetRender renderColumn = (dom.Element element, invokeEvent) {
  return Column(
    mainAxisAlignment: parseAttr(
      element.attributes,
      'mainaxisalignment',
      MainAxisAlignment.start,
      mainAxisAlignment,
    )!,
    crossAxisAlignment: parseAttr(
      element.attributes,
      'crossaxisalignment',
      CrossAxisAlignment.center,
      crossAxisAlignment,
    )!,
    children: renderNodes(element.nodes, invokeEvent),
  );
};

WidgetRender renderContainer = (element, invokeEvent) {
  final radius = parseDirection(element.attributes, 'borderradius');
  return Container(
    decoration: BoxDecoration(
      color: parseAttr(element.attributes, 'color', null, colors),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(radius[Direction.top]!),
        bottomRight: Radius.circular(radius[Direction.right]!),
        bottomLeft: Radius.circular(radius[Direction.bottom]!),
        topLeft: Radius.circular(radius[Direction.left]!),
      ),
    ),
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
  );
};

WidgetRender renderPadding = (element, invokeEvent) {
  return Padding(
    padding: EdgeInsets.only(
      left: attr2double(element.attributes, 'left'),
      right: attr2double(element.attributes, 'right'),
      top: attr2double(element.attributes, 'top'),
      bottom: attr2double(element.attributes, 'bottom'),
    ),
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
  );
};

WidgetRender renderTextButton = (element, invokeEvent) {
  final foregroundColor = colors[element.attributes['foregroundcolor']];
  final disabled = element.attributes['disabled'] != null;
  return TextButton(
    style: ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      foregroundColor: MaterialStateProperty.all(foregroundColor),
    ),
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
    onPressed: disabled
        ? null
        : () {
            invokeEvent(
              element.attributes['onpressed'] ?? 'onpressed',
              createEventData(element.attributes),
            );
          },
  );
};

WidgetRender renderSpacer = (element, invokeEvent) {
  return Spacer(
    flex: int.parse(element.attributes['flex'] ?? '1'),
  );
};

WidgetRender renderText = (element, invokeEvent) {
  return Text(
    element.text,
    style: TextStyle(
      color: parseAttr(
        element.attributes,
        'color',
        null,
        colors,
      ),
      fontWeight: parseAttr(
        element.attributes,
        'fontweight',
        null,
        fontWeight,
      ),
      fontSize: element.attributes['fontsize'] != null
          ? double.parse(element.attributes['fontsize']!)
          : null,
    ),
  );
};

WidgetRender renderIcon = (element, invokeEvent) {
  final icon = element.attributes['icon'] ?? 'download';
  if (!icons.keys.contains(icon)) {
    return Text('unsupport icon: $icon');
  }
  return Icon(
    icons[icon],
    size: double.parse(element.attributes['size'] ?? '20'),
  );
};

WidgetRender renderImage = (element, invokeEvent) {
  if (element.attributes['imageurl'] == null) {
    return Text('需要imageUrl属性');
  }
  return CachedNetworkImage(
    imageUrl: element.attributes['imageurl']!,
    width: element.attributes['width'] != null
        ? double.parse(element.attributes['width']!)
        : null,
    height: element.attributes['width'] != null
        ? double.parse(element.attributes['width']!)
        : null,
  );
};

WidgetRender renderElevatedButton = (element, invokeEvent) {
  final attrs = element.attributes;
  final disabled = element.attributes['disabled'] != null;
  return ElevatedButton(
    onPressed: disabled
        ? null
        : () {
            if (attrs['onpressed'] != null) {
              invokeEvent(
                attrs['onpressed']!,
                createEventData(element.attributes),
              );
            }
          },
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
    style: ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      backgroundColor: colors['backgroundcolor'] != null
          ? MaterialStateProperty.all(colors[attrs['backgroundcolor']!])
          : null,
    ),
  );
};

WidgetRender renderOutlinedButton = (element, invokeEvent) {
  final attrs = element.attributes;
  final disabled = element.attributes['disabled'] != null;
  logger.i(element.attributes);
  return OutlinedButton(
    onPressed: disabled
        ? null
        : () {
            if (attrs['onpressed'] != null) {
              invokeEvent(
                attrs['onpressed']!,
                createEventData(element.attributes),
              );
            }
          },
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
    style: ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      backgroundColor: colors['backgroundcolor'] != null
          ? MaterialStateProperty.all(colors[attrs['backgroundcolor']!])
          : null,
    ),
  );
};

WidgetRender renderDivider = (element, invokeEvent) {
  return Divider(
    color: element.attributes['color'] != null
        ? colors[element.attributes['color']!]
        : null,
  );
};

WidgetRender renderListView = (element, invokeEvent) {
  final children = renderNodes(element.nodes, invokeEvent);
  return ListView.builder(
    itemCount: children.length,
    scrollDirection: parseAttr(
      element.attributes,
      'scrolldirection',
      Axis.vertical,
      scrollDirection,
    )!,
    itemBuilder: (context, index) {
      return children.elementAt(index);
    },
  );
};

WidgetRender renderExpanded = (element, invokeEvent) {
  return Expanded(
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
  );
};

WidgetRender renderSizedBox = (element, invokeEvent) {
  return SizedBox(
    height: element.attributes['height'] != null
        ? double.parse(element.attributes['height']!)
        : null,
    width: element.attributes['width'] != null
        ? double.parse(element.attributes['width']!)
        : null,
    child: getFirstWidget(renderNodes(element.nodes, invokeEvent)),
  );
};

Map<String, WidgetRender> widgetRenderMap = {
  'row': renderRow,
  'column': renderColumn,
  'container': renderContainer,
  'padding': renderPadding,
  'text-button': renderTextButton,
  'text': renderText,
  'spacer': renderSpacer,
  'icon': renderIcon,
  'image': renderImage,
  'img': renderImage,
  'elevated-button': renderElevatedButton,
  'divider': renderDivider,
  'list-view': renderListView,
  'expanded': renderExpanded,
  'sizedbox': renderSizedBox,
  'outlined-button': renderOutlinedButton,
};

List<Widget> renderNodes(
  dom.NodeList nodes,
  InvokeDomEvent invokeEvent,
) {
  return nodes.where((node) => node is dom.Element).map<Widget>((node) {
    final element = node as dom.Element;
    if (widgetRenderMap.keys.contains(element.localName)) {
      return widgetRenderMap[element.localName]!(element, invokeEvent);
    }
    return Text('unsupport element: ${element.localName}');
  }).toList();
}
