import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onPinnedNotes;
  final VoidCallback? onLockedNotes;
  final VoidCallback? onRecycleBin;
  final VoidCallback? onSettings;

  const AppDrawer({
    super.key,
    this.onPinnedNotes,
    this.onLockedNotes,
    this.onRecycleBin,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
              child: Text('Menu'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text(
              'All Notes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text(
              'Pinned Notes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onPinnedNotes?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text(
              'Lock Notes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onLockedNotes?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text(
              'Recycle Bin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onRecycleBin?.call();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              onSettings?.call();
            },
          ),
        ],
      ),
    );
  }
}
