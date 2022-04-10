import 'nodejs.dart';

Future<int> _installPnpm() async {
  final process = await runWithBin('npm', ['install', '-g', 'pnpm']);
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
