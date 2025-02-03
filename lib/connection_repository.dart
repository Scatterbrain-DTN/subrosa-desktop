import 'dart:async';

import 'package:scatterbrain_flutter/mock/scatterbrain/mock_session.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:scatterbrain_flutter/scatterbrain/repository.dart';
import 'package:subrosa/repository.dart';

class ConnectionRepository {
  final ScatterbrainRepository _scatterbrainRepository;
  final SubrosaRepository subrosaRepository;
  final FutureOr<void> Function() onDisconnect;

  ConnectionRepository(
      {required ScatterbrainRepository scatterbrainRepository,
      required this.subrosaRepository,
      required this.onDisconnect})
      : _scatterbrainRepository = scatterbrainRepository;

  Future<void> sendNewsgroup(NewsGroup newsGroup) async {
    try {
      await _scatterbrainRepository.currentSession
          .sendNewsgroup(newsgroup: newsGroup);
    } on Exception {
      await onDisconnect();
    }
  }

  Future<void> sendPost(Posts post) async {
    try {
      await _scatterbrainRepository.currentSession
          .sendPost(post: post, db: subrosaRepository.db);
    } on Exception {
      await onDisconnect();
    }
  }

  Future<void> syncMessage() async {
    try {
      if (_scatterbrainRepository.currentSession is MockSession) {
        return;
      }
      await subrosaRepository.db
          .sync_(sbConnection: _scatterbrainRepository.currentSession);
    } on Exception {
      await onDisconnect();
    }
  }
}
