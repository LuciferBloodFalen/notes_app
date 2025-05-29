import 'package:flutter/material.dart';
import 'main.dart';

class RecycleBinScreen extends StatefulWidget {
  final List<Note> deletedNotes;
  const RecycleBinScreen({super.key, required this.deletedNotes});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndexes.isEmpty
              ? 'Recycle Bin'
              : '${_selectedIndexes.length} selected',
        ),
        actions:
            _selectedIndexes.isEmpty
                ? []
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
                    ? const Center(child: Text('Recycle bin is empty.'))
                    : ListView.builder(
                      itemCount: _binNotes.length,
                      itemBuilder: (context, idx) {
                        final note = _binNotes[idx];
                        final isSelected = _selectedIndexes.contains(idx);
                        return Card(
                          color:
                              isSelected
                                  ? Colors.deepPurple.withOpacity(0.2)
                                  : isDark
                                  ? const Color(0xFF222222)
                                  : Colors.white.withOpacity(0.85),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Icon(
                              note.isFavourite ? Icons.star : Icons.star_border,
                              color:
                                  note.isFavourite ? Colors.amber : Colors.grey,
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
                            subtitle: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
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
