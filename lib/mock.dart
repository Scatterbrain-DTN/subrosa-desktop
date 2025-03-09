import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/mock/pairing/mock_host_record.dart';
import 'package:scatterbrain_flutter/mock/pairing/mock_pair_result.dart';
import 'package:scatterbrain_flutter/mock/pairing/mock_pairing_session.dart';
import 'package:scatterbrain_flutter/mock/scatterbrain/mock_session.dart';
import 'package:scatterbrain_flutter/pairing/search_state.dart';
import 'package:scatterbrain_flutter/rust/api/db/connection.dart';
import 'package:scatterbrain_flutter/rust/api/db/migrations.dart';
import 'package:scatterbrain_flutter/scatterbrain.dart';
import 'package:scatterbrain_flutter/scatterbrain/repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subrosa/config.dart';
import 'package:subrosa/connection_repository.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/repository.dart';

import 'package:scatterbrain_flutter/rust/frb_generated.dart';
import 'package:subrosa/subrosa_content.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  await RustLib.init();
  await setupDirs();
  final db = SubrosaDb(path: '${appDirs.data}/data.sqlite');
  await runMigrations(conn: db);

  // final testGroup = NewsGroup(
  //     uuid: UuidValue.fromString(Uuid().toString()), description: "test");

  // final w = await db.getWatcher();
  // await w.watch(
  //     table: "newsgroup",
  //     cb: (c) async {
  //       print("got callback");
  //     });

  // await testGroup.insert(conn: db);

  final scatterbrainRepository = ScatterbrainRepository(
      record: MockHostRecord(
          session: MockPairingSession(
              coin: [],
              result: MockPairResult(mockSession: MockSession()),
              session:
                  UuidValue.fromString("CDF8F92C-6C99-4CED-8749-DEBABD7D83D8")),
          port: 8888,
          addrs: [],
          name: "test"),
      appName: "test app",
      currentSession: MockSession(),
      config: const CryptoConfig(secretkey: "", pubkey: ""));

  final repository = SubrosaRepository(appDirs: appDirs, db: db);
  runApp(MyApp(
    repository: repository,
    scatterbrainRepository: scatterbrainRepository,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  final SearchState searchState = SearchState(scanner: ServiceScanner());
  final SubrosaRepository repository;
  final ScatterbrainRepository scatterbrainRepository;
  late final newsgroupService = NewsgroupService(repository: repository);

  MyApp(
      {super.key,
      required this.repository,
      required this.scatterbrainRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MultiProvider(
            providers: [
              Provider(create: (ctx) => repository),
              Provider(
                  create: (ctx) => ConnectionRepository(
                      scatterbrainRepository: scatterbrainRepository,
                      onDisconnect: () => (),
                      subrosaRepository: repository))
            ],
            child: SubrosaContent(
                connected: true,
                newsgroupService: newsgroupService,
                repository: repository,
                scanner: searchState,
                prefs: prefs)));
  }
}
