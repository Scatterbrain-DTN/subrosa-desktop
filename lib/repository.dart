import 'package:app_dirs/app_dirs.dart';
import 'package:scatterbrain_flutter/rust/api/db/connection.dart';
import 'package:scatterbrain_flutter/rust/api/db/migrations.dart';

class SubrosaRepository {
  final AppDirs appDirs;
  final SubrosaDb db;

  SubrosaRepository({required this.appDirs, required this.db});

  Future<void> migrate() async {
    await runMigrations(conn: db);
  }
}
