import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';
import 'package:uuid/uuid.dart';

class _CreateGroupDialogState extends State<GroupCreateDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController controller = TextEditingController();

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Empty group names are not allowd';
    }

    return null;
  }

  Future<void> onSave() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await widget.onCreate(NewsGroup(
      uuid: Uuid().v4obj(),
      groupName: controller.text,
      description: "",
      sent: false,
      parent: widget.parent?.asParent(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
                key: formKey,
                child: TextFormField(
                    validator: validator,
                    controller: controller,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter group name'))),
            Row(children: [
              ElevatedButton(
                  onPressed: () async {
                    await onSave();
                    if (context.mounted) await Navigator.maybePop(context);
                  },
                  child: const Text('Create')),
              ElevatedButton(
                  onPressed: () async {
                    await widget.onCreate(null);
                    if (context.mounted) await Navigator.maybePop(context);
                  },
                  child: const Text('Cancel'))
            ])
          ],
        ));
  }
}

class GroupCreateDialog extends StatefulWidget {
  final FutureOr<void> Function(NewsGroup?) onCreate;
  final NewsGroup? parent;
  const GroupCreateDialog({super.key, required this.onCreate, this.parent});

  @override
  State<StatefulWidget> createState() {
    return _CreateGroupDialogState();
  }
}
