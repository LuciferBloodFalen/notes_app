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
    return Scaffold(
      appBar: AppBar(title: const Text('Search Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child:
                _results.isEmpty
                    ? const Center(child: Text('No matching notes found.'))
                    : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white.withOpacity(0.85),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(
                              _results[index].title.isEmpty
                                  ? '(No Title)'
                                  : _results[index].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _results[index].content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
