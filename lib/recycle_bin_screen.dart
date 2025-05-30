import 'package:flutter/material.dart';
import 'main.dart';
import 'search_screen.dart';

class RecycleBinScreen extends StatefulWidget {
  final List<Note> deletedNotes;
  final Widget? drawer;
  const RecycleBinScreen({super.key, required this.deletedNotes, this.drawer});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  late List<Note> _binNotes;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _binNotes = List<Note>.from(widget.deletedNotes);
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _restoreSelected() {
    final restored = _selectedIndexes.map((i) => _binNotes[i]).toList();
    setState(() {
      _binNotes.removeWhere((note) => restored.contains(note));
      _selectedIndexes.clear();
    });
    Navigator.of(context).pop(restored);
  }

  void _deleteForeverSelected() {
    setState(() {
      final toRemove =
          _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (final idx in toRemove) {
        _binNotes.removeAt(idx);
      }
      _selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          child: Text(
            _selectedIndexes.isEmpty
                ? 'Recycle Bin'
                : '${_selectedIndexes.length} selected',
          ),
        ),
        actions:
            _selectedIndexes.isEmpty
                ? [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search Recycle Bin',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => SearchScreen(
                                notes: _binNotes,
                                drawer: widget.drawer,
                              ),
                        ),
                      );
                    },
                  ),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore',
                    onPressed: _restoreSelected,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete Forever',
                    onPressed: _deleteForeverSelected,
                  ),
                ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _binNotes.isEmpty
                    ? const Center(
                      child: Text(
                        'Recycle bin is empty.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _binNotes.length,
                      itemBuilder: (context, idx) {
                        final note = _binNotes[idx];
                        final isSelected = _selectedIndexes.contains(idx);
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
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected: isSelected,
                            onLongPress: () => _toggleSelect(idx),
                            onTap: () => _toggleSelect(idx),
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
