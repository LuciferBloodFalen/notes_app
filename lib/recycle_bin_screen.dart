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
        elevation: 6,
        shadowColor: Colors.deepPurple.withOpacity(0.18),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        title: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            _selectedIndexes.isEmpty
                ? 'Recycle Bin'
                : '${_selectedIndexes.length} selected',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A0033)
                  : Colors.deepPurple.shade50,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
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
                            color:
                                note.isPinned
                                    ? Colors.deepPurple.withOpacity(0.09)
                                    : Theme.of(context).cardColor,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            elevation: isSelected ? 8 : 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side:
                                  isSelected
                                      ? BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2.2,
                                      )
                                      : BorderSide.none,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
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
                                      isSelected
                                          ? Colors.deepPurple
                                          : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                  fontSize: 18,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing:
                                  _selectedIndexes.isNotEmpty
                                      ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => _toggleSelect(idx),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        activeColor: Colors.deepPurple,
                                      )
                                      : null,
                              selected: isSelected,
                              onLongPress: () => _toggleSelect(idx),
                              onTap:
                                  () =>
                                      _selectedIndexes.isNotEmpty
                                          ? _toggleSelect(idx)
                                          : _toggleSelect(idx),
                            ),
                          );
                        },
                      ),
            ),
            if (_selectedIndexes.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore, color: Colors.deepPurple),
                      tooltip: 'Restore Selected',
                      onPressed: _restoreSelected,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.deepPurple,
                      ),
                      tooltip: 'Delete Forever',
                      onPressed: _deleteForeverSelected,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.deepPurple,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'clear':
                            setState(() => _selectedIndexes.clear());
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'clear',
                              child: Row(
                                children: const [
                                  Icon(Icons.clear, color: Colors.deepPurple),
                                  SizedBox(width: 10),
                                  Text('Clear Selection'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
