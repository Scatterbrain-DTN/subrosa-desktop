import 'dart:io';

import 'package:app_dirs/app_dirs.dart';

final appDirs = getAppDirs(application: 'Subrosa');

Future<void> setupDirs() async {
  await Directory(appDirs.data).create(recursive: true);
}
