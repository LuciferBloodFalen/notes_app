import 'package:flutter/material.dart';
import 'main.dart'; // For Note model

class LockedNotesScreen extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;
  final Widget? drawer;

  const LockedNotesScreen({
    super.key,
    required this.notes,
    required this.onNoteTap,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        leading:
            drawer != null
                ? Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                )
                : null,
        title: const DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          child: Text('Lock Notes'),
        ),
        centerTitle: true,
      ),
      body:
          notes.isEmpty
              ? const Center(
                child: Text(
                  'No locked notes.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, idx) {
                  final note = notes[idx];
                  return Card(
                    color: note.cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Colors.deepPurple),
                      title: Text(
                        note.title.isEmpty ? '(No Title)' : note.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => onNoteTap(note),
                    ),
                  );
                },
              ),
    );
  }
}
