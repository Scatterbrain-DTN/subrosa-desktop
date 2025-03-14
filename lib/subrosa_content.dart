import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/pairing/error_dialog.dart';
import 'package:scatterbrain_flutter/pairing/pairing_dialog.dart';
import 'package:scatterbrain_flutter/pairing/search.dart';
import 'package:scatterbrain_flutter/pairing/search_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subrosa/connection_repository.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/repository.dart';
import 'package:subrosa/subrosa_scaffold.dart';

const cutoffLen = 850;

class _SubrosaContentState extends State<SubrosaContent> {
  @override
  void initState() {
    super.initState();
    widget.scanner.startScan();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.connected) {
      return Provider(
          create: (ctx) => widget.repository,
          child: SubrosaScaffold(
              preferences: widget.prefs,
              newsgroupService: widget.newsgroupService,
              scanner: widget.scanner));
    } else {
      return SearchList(
        appName: "desktop test",
        scanner: widget.scanner,
        onConnect: (session, accept, err) {
          if (session != null) {
            showDialog(
                context: context,
                builder: (_) => PairingDialog(
                    session: session,
                    coinText: session.coin.join(' '),
                    prefs: widget.prefs,
                    onPair: (b) => accept(b)));
          } else {
            showDialog(
                context: context,
                builder: (_) => ErrorDialog(
                      errorText: err.toString(),
                    ));
          }
          return null;
        },
        prefs: widget.prefs,
        onPair: (repository, session, onDisconnect, err) {
          return MultiProvider(
              providers: [
                Provider(create: (ctx) => widget.repository),
                Provider(
                    create: (ctx) => ConnectionRepository(
                        scatterbrainRepository: repository,
                        onDisconnect: onDisconnect,
                        subrosaRepository: widget.repository))
              ],
              child: SubrosaScaffold(
                newsgroupService: widget.newsgroupService,
                preferences: widget.prefs,
                scanner: widget.scanner,
              ));
        },
      );
    }
  }
}

class SubrosaContent extends StatefulWidget {
  final SharedPreferencesAsync prefs;
  final NewsgroupService newsgroupService;
  final SubrosaRepository repository;
  final SearchState scanner;
  final bool connected;

  const SubrosaContent(
      {super.key,
      this.connected = false,
      required this.prefs,
      required this.newsgroupService,
      required this.repository,
      required this.scanner});

  @override
  State<StatefulWidget> createState() {
    return _SubrosaContentState();
  }
}
