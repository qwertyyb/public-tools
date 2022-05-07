import 'package:path_provider/path_provider.dart';

import 'nodejs.dart';

Future<String> _getPnpmStorePath() async {
  final supportDir = await getApplicationSupportDirectory();
  return '${supportDir.path}/pnpm-store';
}

Future<int> _installPnpm() async {
  final process = await runWithBin('npm', ['install', '-g', 'pnpm']);
  final storePath = await _getPnpmStorePath();
  await runWithBin('pnpm', ['pnpm', 'config', 'set', 'store-dir', storePath]);
  return process.exitCode;
}

Future<int> _installRemoteCore() async {
  await runWithBin('which', ['pnpm']);
  final process =
      await runWithBin('pnpm', ['add', '@public-tools/core@latest']);
  return process.exitCode;
}

Future _runRemote() async {
  runWithBin('pnpx', ['public-tools']);
}

Future startRemote() async {
  await downloadNodeJs();
  await _installPnpm();
  await _installRemoteCore();
  _runRemote();
}
