import 'package:flutter/material.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:subrosa/groups/group_path.dart';

class GroupPathView extends StatelessWidget {
  final List<NewsGroup> parents;
  final double height;

  const GroupPathView({super.key, required this.parents, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: ListView.builder(
            itemCount: parents.length + 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) => switch (index) {
                  0 => GroupPath(group: "/"),
                  _ => GroupPath(group: parents[index - 1].groupName)
                }));
  }
}
