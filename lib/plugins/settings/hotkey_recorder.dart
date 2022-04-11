import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../utils/logger.dart';

class HotKeyRecorderView extends StatefulWidget {
  final bool disabled;
  final HotKey? hotKey;
  final bool canRemove;

  final void Function(HotKey?)? onHotKeyRecorded;

  HotKeyRecorderView({
    this.onHotKeyRecorded,
    this.hotKey,
    this.disabled = false,
    this.canRemove = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _HotKeyRecorderViewState();
  }
}

class _HotKeyRecorderViewState extends State<HotKeyRecorderView> {
  bool _isRecordingHotKey = false;

  @override
  void initState() {
    super.initState();
  }

  void _onHotKeyRecorded(HotKey? hotKey) {
    logger.i("hotKey recorded: $hotKey");
    setState(() {
      _isRecordingHotKey = false;
    });
    widget.onHotKeyRecorded?.call(hotKey);
  }

  @override
  Widget build(BuildContext context) {
    return widget.disabled
        ? OutlinedButton(onPressed: null, child: Text('--'))
        : OutlinedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              foregroundColor: MaterialStateProperty.all(Colors.deepPurple),
              textStyle: MaterialStateProperty.all(
                  TextStyle(fontWeight: FontWeight.normal)),
            ),
            onPressed: () {
              setState(() {
                _isRecordingHotKey = !_isRecordingHotKey;
              });
            },
            child: _isRecordingHotKey
                ? Stack(
                    children: [
                      HotKeyRecorder(
                        initalHotKey: widget.hotKey,
                        onHotKeyRecorded: _onHotKeyRecorded,
                      ),
                      Text('按下键盘快捷键', style: TextStyle(fontSize: 12)),
                    ],
                  )
                : widget.hotKey != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HotKeyVirtualView(hotKey: widget.hotKey!),
                          if (widget.canRemove)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: InkWell(
                                onTap: () {
                                  _onHotKeyRecorded(null);
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Text('点击设置'),
          );
  }
}
