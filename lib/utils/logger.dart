import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) async {
    final now = DateTime.now();
    final time = now.toIso8601String();
    final formatted = event.lines.map((line) => '$time: $line').join('\n');
    final supportDir = await getApplicationSupportDirectory();
    final logPath = '${supportDir.path}/logs';
    final file = File('$logPath/app.log');
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }
    final writer = file.openWrite(mode: FileMode.append);
    writer.writeln(formatted);
    writer.close();
  }
}

final logger = Logger(
  output: kReleaseMode ? FileOutput() : null,
  filter: AppLogFilter(),
);
