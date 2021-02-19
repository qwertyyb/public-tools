import 'package:flutter/material.dart';

class MainView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(),
        Expanded(child: Column(
          children: [
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.history_toggle_off_outlined, size: 30)],
              ),
              title: Text("toggle"),
              subtitle: Text("subtitle"),
            )
          ],
        ))
      ],
    );
  }
}