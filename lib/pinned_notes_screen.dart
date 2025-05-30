import 'package:flutter/material.dart';
import 'main.dart'; // For Note model
import 'search_screen.dart'; // Import SearchScreen

class PinnedNotesScreen extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;
  final Widget? drawer;

  const PinnedNotesScreen({
    super.key,
    required this.notes,
    required this.onNoteTap,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Text('Pinned Notes'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Pinned Notes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => SearchScreen(notes: notes, drawer: drawer),
                ),
              );
            },
          ),
        ],
      ),
      body:
          notes.isEmpty
              ? const Center(
                child: Text(
                  'No pinned notes.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, idx) {
                  final note = notes[idx];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        note.title.isEmpty ? '(No Title)' : note.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.push_pin,
                        color: Colors.deepPurple,
                      ),
                      onTap: () => onNoteTap(note),
                    ),
                  );
                },
              ),
    );
  }
}
