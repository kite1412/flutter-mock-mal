import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void mShowDialog(
  BuildContext context,
  String title,
  VoidCallback onConfirmed
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
                "Cancel",
                style: Theme.of(context).textTheme.bodyLarge
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirmed();
              Navigator.of(context).pop();
            },
            child: Text(
              "Yes",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.red),
            )
          ),
        ],
      );
    },
  );
}