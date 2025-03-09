import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/pairing/search_state.dart';
import 'package:scatterbrain_flutter/rust/api.dart';
import 'package:scatterbrain_flutter/rust/frb_generated.dart';
import 'package:scatterbrain_flutter/rust/api/db/connection.dart';
import 'package:scatterbrain_flutter/rust/api/db/migrations.dart';
import 'package:scatterbrain_flutter/rust/third_party/scatterbrain/api/mdns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subrosa/config.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/repository.dart';

import 'package:subrosa/subrosa_content.dart';

Future<void> main() async {
  await RustLib.init();
  await setupDirs();
  final db = SubrosaDb(path: '${appDirs.data}/data.sqlite');
  await runMigrations(conn: db);
  await initLogging();
  runApp(MyApp(repository: SubrosaRepository(appDirs: appDirs, db: db)));
}

class MyApp extends StatelessWidget {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  final SubrosaRepository repository;
  late final newsGroupService = NewsgroupService(repository: repository);
  final SearchState searchState = SearchState(scanner: ServiceScanner());

  MyApp({super.key, required this.repository});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SubrosaContent(
          prefs: prefs,
          newsgroupService: newsGroupService,
          repository: repository,
          scanner: searchState,
          connected: false,
        ));
  }
}
