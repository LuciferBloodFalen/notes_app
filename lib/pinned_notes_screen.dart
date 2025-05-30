import 'package:flutter/material.dart';
import 'main.dart'; // For Note model
import 'search_screen.dart'; // Import SearchScreen

class PinnedNotesScreen extends StatefulWidget {
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
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  final Set<int> _selectedIndexes = {};
  bool get _isSelectionMode => _selectedIndexes.isNotEmpty;

  void _toggleSelect(int idx) {
    setState(() {
      if (_selectedIndexes.contains(idx)) {
        _selectedIndexes.remove(idx);
      } else {
        _selectedIndexes.add(idx);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndexes.clear();
    });
  }

  void _deleteSelected() {
    setState(() {
      final toRemove =
          _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (final idx in toRemove) {
        widget.notes.removeAt(idx);
      }
      _selectedIndexes.clear();
    });
  }

  void _togglePinSelected() {
    setState(() {
      for (final idx in _selectedIndexes) {
        widget.notes[idx].isPinned = !widget.notes[idx].isPinned;
      }
      _selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.notes;
    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        elevation: 6,
        shadowColor: Colors.deepPurple.withOpacity(0.18),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        title: const DefaultTextStyle(
          style: TextStyle(
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
          child: Text('Pinned Notes'),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Pinned Notes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          SearchScreen(notes: notes, drawer: widget.drawer),
                ),
              );
            },
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
                                  _isSelectionMode
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
                                      : const Icon(
                                        Icons.push_pin,
                                        color: Colors.deepPurple,
                                      ),
                              selected: isSelected,
                              onLongPress: () => _toggleSelect(idx),
                              onTap:
                                  () =>
                                      _isSelectionMode
                                          ? _toggleSelect(idx)
                                          : widget.onNoteTap(note),
                            ),
                          );
                        },
                      ),
            ),
            if (_isSelectionMode)
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
                      icon: Icon(
                        notes.isNotEmpty &&
                                _selectedIndexes.isNotEmpty &&
                                _selectedIndexes.every(
                                  (idx) => notes[idx].isPinned,
                                )
                            ? Icons.push_pin_outlined
                            : Icons.push_pin,
                        color: Colors.deepPurple,
                      ),
                      tooltip:
                          notes.isNotEmpty &&
                                  _selectedIndexes.isNotEmpty &&
                                  _selectedIndexes.every(
                                    (idx) => notes[idx].isPinned,
                                  )
                              ? 'Unpin Selected'
                              : 'Pin Selected',
                      onPressed: _togglePinSelected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.deepPurple),
                      tooltip: 'Delete Selected',
                      onPressed: _deleteSelected,
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
                            _clearSelection();
                            break;
                          // Add more bulk actions here if needed
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
