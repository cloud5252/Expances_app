import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final String date;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.date,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.4,

        children: [
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.settings,
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(5),
            flex: 1,
          ),

          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(5),
            flex: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          tileColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabled: true,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
            ),
          ),
          subtitle: Text(date),
          trailing: Text(
            trailing.toString(),
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
