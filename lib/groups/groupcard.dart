import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:subrosa/groups/context_menu_test.dart';
import 'package:uuid/uuid.dart';

enum GroupCardAction { delete }

_default(GroupCardAction _, UuidValue v) {}
void _def() {}

const identiconWidth = 48.0;
const menuIconWidth = 16.0;
const textWidth = 304 - identiconWidth;

class Groupcard extends StatelessWidget {
  final String name;
  final UuidValue id;
  final double minWidth;
  final OnTap onTap;
  final FutureOr<void> Function(GroupCardAction, UuidValue) onAction;

  const Groupcard(
      {super.key,
      required this.name,
      required this.id,
      this.minWidth = identiconWidth + menuIconWidth + 128.0,
      this.onTap = _def,
      this.onAction = _default});

  @override
  Widget build(BuildContext context) {
    String svg = Jdenticon.toSvg(id.uuid);
    final theme = Theme.of(context);

    return ContextMenuRegion(
        onTap: onTap,
        contextMenuBuilder: (ctx, offset) {
          return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: TextSelectionToolbarAnchors(primaryAnchor: offset),
              buttonItems: [
                ContextMenuButtonItem(
                    onPressed: () async {
                      await onAction(GroupCardAction.delete, id);
                      ContextMenuController.removeAny();
                    },
                    label: 'Delete')
              ]);
        },
        child: Row(
          children: [
            OverflowBar(children: [
              SvgPicture.string(
                svg,
                width: identiconWidth,
              ),
              SizedBox(
                  width: textWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, textAlign: TextAlign.start),
                      Text(
                        id.uuid,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.labelSmall,
                      )
                    ],
                  ))
            ]),
          ],
        ));
    // });
  }
}
