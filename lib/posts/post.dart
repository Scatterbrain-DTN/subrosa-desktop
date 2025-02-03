import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:uuid/uuid.dart';

enum PostAction { delete }

_default(PostAction _, UuidValue v) {}

class Post extends StatelessWidget {
  final Posts posts;
  final CachedIdentity? identity;
  final FutureOr<void> Function(PostAction, UuidValue) onAction;

  const Post(
      {super.key,
      required this.posts,
      this.identity,
      this.onAction = _default});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    posts.header ?? "no subject",
                    style: theme.textTheme.titleMedium,
                  ),
                  Spacer(flex: 1),
                  Text(
                    identity?.userName ?? "anonymous",
                    style: theme.textTheme.labelLarge,
                  )
                ]),
                Text(
                  posts.body ?? "",
                  textAlign: TextAlign.start,
                ),
                if (posts.identity != null)
                  Text(posts.identity!.toFormattedString(),
                      style: theme.textTheme.labelSmall)
              ],
            )));
  }
}
