import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:subrosa/connection_repository.dart';
import 'package:subrosa/groups/group_create_dialog.dart';
import 'package:subrosa/groups/group_path_view.dart';
import 'package:subrosa/groups/groupcard.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/repository.dart';

void _def(NewsGroup? _) {}

typedef GroupClickAction = FutureOr<void> Function(NewsGroup?);

class GroupListState extends State<GroupList> {
  List<NewsGroup> parents = [];

  @override
  void initState() {
    super.initState();
    parents = widget.groupState.parents;
    widget.groupState.onState(onUpdate);
  }

  void onUpdate(
      NewsGroup? parent, List<NewsGroup> groups, List<NewsGroup> parents) {
    setState(() {
      this.parents = parents;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.groupState.disposeState(onUpdate);
  }

  Widget scrollList(BuildContext context) {
    final groups = widget.groupState.groups;
    if (groups.isNotEmpty) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: groups.length,
          itemBuilder: (ctx, index) {
            final next = groups.elementAtOrNull(index);

            return Consumer<SubrosaRepository>(
                builder: (ctx, repo, child) => Groupcard(
                    onAction: (action, id) async => (switch (action) {
                          GroupCardAction.delete =>
                            await repo.db.deleteGroup(uuid: id)
                        }),
                    name: groups[index].groupName,
                    onTap: () async {
                      widget.groupState.down(next);
                      await widget.listener(next);
                    },
                    id: groups[index].uuid));
          });
    } else {
      return Text("No groups found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Column(
          children: [
            Consumer<ConnectionRepository>(
                builder: (ctx, repo, child) => IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (ctx) {
                            return Dialog(
                                child: GroupCreateDialog(
                                    parent: widget.groupState.parent,
                                    onCreate: (create) async {
                                      if (create != null) {
                                        await repo.subrosaRepository.db
                                            .insertGroup(group: create);

                                        await repo.sendNewsgroup(create);
                                      }
                                    }));
                          });
                    },
                    icon: const Icon(Icons.group_add))),
            if (widget.showGroups || widget.groupState.parent == null)
              IconButton(
                  onPressed: () async => await widget.groupState.up(),
                  icon: const Icon(Icons.arrow_upward)),
          ],
        ),
        Expanded(
            child: GroupPathView(
          parents: parents,
        ))
      ]),
      Expanded(child: scrollList(context))
    ]);
  }
}

class GroupList extends StatefulWidget {
  final GroupClickAction listener;
  final NewsgroupService groupState;
  final bool showGroups;
  const GroupList({
    super.key,
    required this.groupState,
    required this.showGroups,
    this.listener = _def,
  });

  @override
  State<StatefulWidget> createState() {
    return GroupListState();
  }
}
