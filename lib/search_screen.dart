import 'package:flutter/material.dart';
import 'main.dart'; // Use the Note model from main.dart

class SearchScreen extends StatefulWidget {
  final List<Note> notes;

  const SearchScreen({super.key, required this.notes});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  List<Note> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List<Note>.from(widget.notes.reversed);
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _results =
          widget.notes
              .where(
                (note) =>
                    note.title.toLowerCase().contains(query.toLowerCase()) ||
                    note.content.toLowerCase().contains(query.toLowerCase()),
              )
              .toList()
              .reversed
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      appBar: AppBar(
        title: const DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          child: Text('Search Notes'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Search notes...'),
              onChanged: _search,
            ),
          ),
          Expanded(
            child:
                _results.isEmpty
                    ? const Center(
                      child: Text(
                        'No matching notes found.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final note = _results[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Icon(
                              note.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color:
                                  note.isPinned
                                      ? Colors.deepPurple
                                      : Colors.grey,
                            ),
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
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
