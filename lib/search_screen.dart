import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Use the Note model from main.dart

class SearchScreen extends StatefulWidget {
  final List<Note> notes;
  final Widget? drawer;

  const SearchScreen({super.key, required this.notes, this.drawer});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Note> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List<Note>.from(widget.notes.reversed);
  }

  void _search(String query) {
    setState(() {
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

  void _announce(String message, BuildContext context) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        leading:
            widget.drawer != null
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
          child: Text('Search Notes'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
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
                          elevation: 2,
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
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _announce(
                                'Selected note: ${note.title}',
                                context,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected note: ${note.title}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            onLongPress: () {
                              HapticFeedback.lightImpact();
                              _announce(
                                'Long pressed note: ${note.title}',
                                context,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Long pressed note: ${note.title}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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
