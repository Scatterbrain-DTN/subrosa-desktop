import 'package:flutter/material.dart';
import 'package:scatterbrain_flutter/rust/api/db/connection.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:subrosa/groups/newsgroup_service.dart';
import 'package:subrosa/posts/post.dart';
import 'package:subrosa/repository.dart';
import 'package:uuid/uuid.dart';

class _PostListState extends State<PostList> {
  late final Watcher watcher;
  List<Posts> posts = [];

  @override
  void initState() {
    super.initState();
    watcher = widget.repository.db.getWatcher();
    widget.newsgroupService.onState(onUpdate);
    watcher.watch(
        table: "posts",
        cb: (c) async {
          final posts = switch (widget.parent) {
            null => <Posts>[],
            (UuidValue v) => await c.getPosts(parent: v)
          };

          setState(() {
            this.posts = posts;
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    watcher.dispose();
    widget.newsgroupService.disposeState(onUpdate);
  }

  Future<void> onUpdate(NewsGroup? parent, List<NewsGroup> groups,
      List<NewsGroup> parents) async {
    final parent = widget.newsgroupService.parent;
    final posts = switch (parent) {
      null => <Posts>[],
      _ => await widget.repository.db.getPosts(parent: parent.uuid)
    };
    setState(() {
      this.posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isNotEmpty) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: posts.length,
          itemBuilder: (ctx, index) {
            return Post(
                onAction: (action, id) async => (switch (action) {
                      PostAction.delete =>
                        await widget.repository.db.deletePost(uuid: id)
                    }),
                posts: posts[index]);
          });
    } else {
      return const Text("No posts found");
    }
  }
}

class PostList extends StatefulWidget {
  final SubrosaRepository repository;
  final NewsgroupService newsgroupService;
  final UuidValue? parent;
  const PostList(
      {super.key,
      required this.repository,
      required this.newsgroupService,
      this.parent});

  @override
  State<StatefulWidget> createState() {
    return _PostListState();
  }
}
