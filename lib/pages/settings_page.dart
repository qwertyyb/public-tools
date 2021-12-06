import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ListView(
          children: [
            Container(
              child: Text('基础'),
            )
          ],
        )
      ],
    );
  }
}
