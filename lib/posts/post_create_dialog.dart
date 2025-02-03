import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scatterbrain_flutter/rust/api/db/entities.dart';

class _PostCreateDialogState extends State<PostCreateDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController controller = TextEditingController();
  final TextEditingController headerController = TextEditingController();

  Future<void> onSave() async {
    await widget.onCreate(Posts(
        header: headerController.text,
        body: controller.text,
        group: widget.group.uuid));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('New post'),
            Form(
                child: TextFormField(
              controller: headerController,
              maxLines: null,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(), labelText: "Subject"),
            )),
            Form(
                child: TextFormField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "What's on your mind?"),
            )),
            Row(children: [
              ElevatedButton(
                  onPressed: () async {
                    await onSave();
                    if (context.mounted) await Navigator.maybePop(context);
                  },
                  child: const Text('Create')),
              ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) await Navigator.maybePop(context);
                  },
                  child: const Text('Cancel'))
            ])
          ],
        ));
  }
}

class PostCreateDialog extends StatefulWidget {
  final NewsGroup group;
  final FutureOr<void> Function(Posts?) onCreate;

  const PostCreateDialog(
      {super.key, required this.group, required this.onCreate});

  @override
  State<StatefulWidget> createState() {
    return _PostCreateDialogState();
  }
}
