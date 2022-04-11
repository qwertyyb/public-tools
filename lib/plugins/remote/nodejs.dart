import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../utils/logger.dart';

const downloadUrl =
    'https://nodejs.org/dist/v16.13.0/node-v16.13.0-darwin-x64.tar.gz';

Future<String> downloadNodeJs() async {
  final dir = await getApplicationSupportDirectory();
  final filePath = '${dir.path}/node-v16.13.0-darwin-x64.tar.gz';
  final nodeDir = '${dir.path}/node-v16.13.0-darwin-x64';
  final binDir = '$nodeDir/bin';
  final npmPath = '$binDir/npm';
  final nodePath = '$binDir/node';
  if (File(npmPath).existsSync() && File(nodePath).existsSync()) {
    return binDir;
  }
  // 删除文件，重新下载
  if (File(npmPath).existsSync() || File(nodePath).existsSync()) {
    Directory(nodeDir).deleteSync(recursive: true);
  }
  if (File(filePath).existsSync()) {
    File(filePath).deleteSync();
  }
  final request = await HttpClient().getUrl(Uri.parse(downloadUrl));
  final response = await request.close();
  final file = File(filePath);
  await response.pipe(file.openWrite()).catchError((error) {
    file.deleteSync();
    logger.e('download nodejs error: $error');
    throw error;
  }, test: (error) => false);
  logger.i('download success');
  final process = await Process.run(
    "tar",
    ['-zxf', 'node-v16.13.0-darwin-x64.tar.gz'],
    workingDirectory: dir.path,
  );
  final exitCode = process.exitCode;
  if (exitCode != 0) {
    file.deleteSync();
    throw Exception('download nodejs error');
  }
  logger.i('untar success');
  return binDir;
}

Future initWorkingDir(String workingDir) async {
  final directory = Directory(workingDir);
  final exists = await directory.exists();
  if (!exists) {
    await directory.create(recursive: true);
  }
  final File pkgFile = File('${directory.path}/package.json');
  if (await pkgFile.exists()) return;
  await pkgFile.writeAsString('{}', flush: true);
}

Future<Process> runWithBin(String executable, List<String> arguments) async {
  final supportPath = await getApplicationSupportDirectory();
  final nodePath = '${supportPath.path}/node-v16.13.0-darwin-x64';
  final binPath = '$nodePath/bin';
  final workingDir = '${supportPath.path}/plugins';
  await initWorkingDir(workingDir);

  final newEnv = Map<String, String>.from(Platform.environment);
  newEnv['PATH'] = '$binPath:${newEnv['PATH']}';

  final clientProcess = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDir,
    environment: newEnv,
    runInShell: true,
  );
  clientProcess.stdout.transform(utf8.decoder).forEach(print);
  clientProcess.stderr.transform(utf8.decoder).forEach(print);
  clientProcess.exitCode.then((code) {
    print('client exit code: $code');
  });
  return clientProcess;
}
