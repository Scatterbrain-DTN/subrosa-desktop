import 'dart:async';
import 'dart:collection';

import 'package:scatterbrain_flutter/rust/api/db/connection.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:subrosa/repository.dart';

import 'package:uuid/uuid.dart';

typedef OnGroups = FutureOr<void> Function(
    NewsGroup?, List<NewsGroup>, List<NewsGroup>);

class NewsgroupService {
  late final Watcher _watcher;
  final SubrosaRepository repository;
  NewsGroup? parent;
  List<NewsGroup> groups;
  List<NewsGroup> parents;
  late final HashSet<OnGroups> _cbs;

  void onState(OnGroups cb) {
    _cbs.add(cb);
  }

  void disposeState(OnGroups cb) {
    _cbs.remove(cb);
  }

  Future<void> updateParents() async {
    if (parent != null) {
      final parents = await repository.db.getParents(group: parent!.uuid);
      this.parents = parents;
    } else {
      parents = [];
    }
  }

  Future<List<NewsGroup>> getGroups() async {
    return switch (parent?.uuid) {
      null => await repository.db.getRootGroups(),
      (UuidValue v) => await repository.db.getGroupsForParent(parent: v)
    };
  }

  Future<void> up() async {
    if (parent?.parent != null) {
      parent = await repository.db.getGroup(uuid: parent!.parent!);
    } else {
      parent = null;
    }

    await updateParents();

    groups = await getGroups();

    for (final cb in _cbs) {
      await cb(parent, groups, parents);
    }
  }

  Future<void> down(NewsGroup? next) async {
    parent = next;
    if (parent != null) {
      await parent!
          .insertOnConflict(conn: repository.db, onConflict: OnConflict.ignore);
    }
    await updateParents();
    groups = await getGroups();
    for (final cb in _cbs) {
      await cb(parent, groups, parents);
    }
  }

  NewsgroupService(
      {required this.repository,
      this.parent,
      this.groups = const [],
      this.parents = const []}) {
    _cbs = HashSet();

    _watcher = repository.db.getWatcher();
    _watcher.watch(
        table: "newsgroup",
        cb: (c) async {
          groups = await getGroups();
          for (final cb in _cbs) {
            await cb(parent, groups, parents);
          }
        });
  }
}
