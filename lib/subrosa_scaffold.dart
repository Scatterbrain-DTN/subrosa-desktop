import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/pairing/search_state.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subrosa/app_test.dart';
import 'package:subrosa/connection_repository.dart';
import 'package:subrosa/groups/group_list.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/posts/post_create_dialog.dart';
import 'package:subrosa/subrosa_content.dart';

class _SubrosaScaffoldState extends State<SubrosaScaffold> {
  @override
  void initState() {
    super.initState();
    widget.newsgroupService.onState(onState);
  }

  void onState(
      NewsGroup? parent, List<NewsGroup> groups, List<NewsGroup> parents) {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.newsgroupService.disposeState(onState);
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.newsgroupService.parent;
    final showGroups = MediaQuery.sizeOf(context).width > cutoffLen;
    Drawer? drawer;

    return Consumer<ConnectionRepository>(
        builder: (context, repository, child) {
      if (!showGroups && widget.newsgroupService.parent != null) {
        drawer = Drawer(
            child: GroupList(
          groupState: widget.newsgroupService,
          showGroups: true,
        ));
      }
      return Scaffold(
        drawer: drawer,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async => await repository.syncMessage(),
              icon: Icon(Icons.sync),
            ),
            IconButton(
                onPressed: () async => await widget.preferences.clear(),
                icon: Icon(Icons.logout))
          ],
          title: const Text('Local newsnet groups'),
        ),
        floatingActionButton: switch (parent) {
          null => null,
          _ => FloatingActionButton(onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (ctx) {
                    return Dialog(
                        child: PostCreateDialog(
                      group: parent,
                      onCreate: (post) async {
                        await post?.insert(
                            conn: repository.subrosaRepository.db);

                        if (post != null) {
                          await repository.sendPost(
                            post,
                          );
                        }
                      },
                    ));
                  });
            }),
        },
        body: Center(
          child: AppTest(
            newsgroupService: widget.newsgroupService,
            showGroups: showGroups,
          ),
        ),
      );
    });
  }
}

class SubrosaScaffold extends StatefulWidget {
  final NewsgroupService newsgroupService;
  final SharedPreferencesAsync preferences;
  final SearchState scanner;

  const SubrosaScaffold(
      {super.key,
      required this.newsgroupService,
      required this.preferences,
      required this.scanner});

  @override
  State<StatefulWidget> createState() {
    return _SubrosaScaffoldState();
  }
}
