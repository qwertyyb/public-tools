import 'package:flutter/material.dart';

import 'result_item_view.dart';

class SearchResultList<T> extends StatefulWidget {
  final List<T> list;

  final int selectedIndex;

  final void Function(T item, int index)? onTap;

  SearchResultList({
    Key? key,
    required this.list,
    this.onTap,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  final scrollController = new ScrollController();

  @override
  void didUpdateWidget(covariant SearchResultList oldWidget) {
    // 计算是否需要滚动
    final visibleMinIndex = (scrollController.offset / 48).ceil();
    final visibleMaxIndex = visibleMinIndex + 8;
    final visible = visibleMinIndex <= widget.selectedIndex &&
        widget.selectedIndex <= visibleMaxIndex;
    if (!visible) {
      // 根据当前滚动的位置，和要滚动的位置，计算向上还是向下滚动
      final nextOffset = 48.0 * (widget.selectedIndex - 8);
      final isScrollDown = nextOffset > scrollController.offset;
      if (isScrollDown) {
        scrollController.jumpTo(nextOffset);
      } else {
        scrollController.jumpTo(widget.selectedIndex * 48.0);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 2,
        child: ListView.builder(
          controller: scrollController,
          itemBuilder: (pluginContext, itemIndex) {
            var resultItem = widget.list.elementAt(itemIndex);
            var pluginView = ResultItemView(
              item: resultItem.value,
              selected: itemIndex == widget.selectedIndex,
              onTap: () {
                widget.onTap?.call(resultItem, itemIndex);
              },
            );
            return pluginView;
          },
          itemCount: widget.list.length,
        ),
      ),
    ]);
  }
}
