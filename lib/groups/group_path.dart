import 'package:flutter/material.dart';
import 'package:subrosa/groups/group_path_element.dart';

class GroupPath extends StatelessWidget {
  final String group;

  const GroupPath({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const GroupPathElement(),
      child: Container(
        color: Colors.black,
        constraints: BoxConstraints(minWidth: 64.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
              child: Text(
            group,
            style: TextStyle(color: Colors.white),
          )),
        ),
      ),
    );
  }
}
