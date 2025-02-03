import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';

import 'package:subrosa/groups/group_list.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/posts/post_list.dart';
import 'package:subrosa/repository.dart';

void _def(NewsGroup? _) {}

typedef GroupChangeListener = FutureOr<void> Function(NewsGroup?);

class AppTestState extends State<AppTest> {
  Axis direction = Axis.horizontal;
  int messageCount = 0;
  Size? size;
  BoxConstraints? constraints;

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
    // ClipPath(
    //   clipper: GroupPathElement(),
    //   child: Container(
    //     color: Colors.black,
    //   ),
    // );
    return Consumer<SubrosaRepository>(
        builder: (ctx, repo, child) => Flex(
              direction: direction,
              children: [
                if (widget.showGroups || widget.newsgroupService.parent == null)
                  Flexible(
                      flex: 3,
                      child: GroupList(
                        groupState: widget.newsgroupService,
                        showGroups: widget.showGroups,
                      )),
                if (widget.newsgroupService.parent != null)
                  Flexible(
                      flex: 4,
                      child: PostList(
                        repository: repo,
                        newsgroupService: widget.newsgroupService,
                        parent: widget.newsgroupService.parent?.uuid,
                      ))
              ],
            ));
  }
}

class AppTest extends StatefulWidget {
  final bool showGroups;
  final GroupChangeListener listener;
  final NewsgroupService newsgroupService;

  const AppTest(
      {super.key,
      required this.newsgroupService,
      this.listener = _def,
      this.showGroups = true});

  @override
  State<StatefulWidget> createState() {
    return AppTestState();
  }
}
