import 'package:flutter/material.dart';
import 'note_edit_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'recycle_bin_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesHomePage(onThemeChanged: _setThemeMode, themeMode: _themeMode),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        brightness: Brightness.light,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        brightness: Brightness.dark,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF222222),
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      themeMode: _themeMode,
    );
  }
}

// Note model with title, content, and favourite flag
class Note {
  String title;
  String content;
  bool isFavourite;
  Note({required this.title, required this.content, this.isFavourite = false});
}

class NotesHomePage extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? themeMode;
  const NotesHomePage({super.key, this.onThemeChanged, this.themeMode});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final List<Note> _notes = [];
  final Set<int> _selectedIndexes = {};
  final List<Note> _recycleBin = [];

  bool get _isSelectionMode => _selectedIndexes.isNotEmpty;

  void _openNoteEditScreen({int? index}) async {
    if (_isSelectionMode) return; // Prevent editing while selecting
    final isEditing = index != null && index! >= 0 && index < _notes.length;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NoteEditScreen(
              initialTitle: isEditing ? _notes[index!].title : null,
              initialContent: isEditing ? _notes[index!].content : null,
              isFavourite: isEditing ? _notes[index!].isFavourite : false,
              onSave: (title, content, isFavourite) {
                if (title.trim().isEmpty && content.trim().isEmpty) return;
                setState(() {
                  if (isEditing) {
                    _notes[index!] = Note(
                      title: title,
                      content: content,
                      isFavourite: isFavourite,
                    );
                  } else {
                    _notes.add(
                      Note(
                        title: title,
                        content: content,
                        isFavourite: isFavourite,
                      ),
                    );
                  }
                });
              },
            ),
      ),
    );
  }

  void _toggleFavourite(int index) {
    setState(() {
      _notes[index].isFavourite = !_notes[index].isFavourite;
    });
  }

  void _deleteNote(int index) {
    if (index < 0 || index >= _notes.length) return;
    setState(() {
      _recycleBin.add(_notes[index]);
      _notes.removeAt(index);
    });
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
        _recycleBin.add(_notes[idx]);
        _notes.removeAt(idx);
      }
      _selectedIndexes.clear();
    });
  }

  void _toggleFavouriteSelected() {
    setState(() {
      for (final idx in _selectedIndexes) {
        _notes[idx].isFavourite = !_notes[idx].isFavourite;
      }
      _selectedIndexes.clear();
    });
  }

  void _openSettingsScreen() async {
    final result = await Navigator.of(context).push<ThemeMode>(
      MaterialPageRoute(
        builder:
            (context) => SettingsScreen(
              currentThemeMode: widget.themeMode ?? ThemeMode.light,
            ),
      ),
    );
    if (result != null) {
      widget.onThemeChanged?.call(result);
    }
  }

  void _openRecycleBinScreen() async {
    final restoredNotes = await Navigator.of(context).push<List<Note>>(
      MaterialPageRoute(
        builder:
            (context) =>
                RecycleBinScreen(deletedNotes: List<Note>.from(_recycleBin)),
      ),
    );
    if (restoredNotes != null) {
      setState(() {
        _notes.addAll(restoredNotes);
        _recycleBin.removeWhere((note) => restoredNotes.contains(note));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Favourites first, then others
    final sortedNotes = [
      ..._notes.where((n) => n.isFavourite),
      ..._notes.where((n) => !n.isFavourite),
    ];
    // Map sortedNotes to their original indexes for selection
    final sortedIndexes = [
      ..._notes
          .asMap()
          .entries
          .where((e) => e.value.isFavourite)
          .map((e) => e.key),
      ..._notes
          .asMap()
          .entries
          .where((e) => !e.value.isFavourite)
          .map((e) => e.key),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Recycle Bin'),
              onTap: () {
                Navigator.pop(context);
                _openRecycleBinScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettingsScreen();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedIndexes.length} selected' : 'Notes',
        ),
        centerTitle: true,
        actions:
            _isSelectionMode
                ? [
                  IconButton(
                    icon: const Icon(Icons.star),
                    tooltip: 'Toggle Favourite',
                    onPressed: _toggleFavouriteSelected,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Selected',
                    onPressed: _deleteSelected,
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear Selection',
                    onPressed: _clearSelection,
                  ),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search Notes',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(notes: _notes),
                        ),
                      );
                    },
                  ),
                ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                sortedNotes.isEmpty
                    ? const Center(child: Text('No notes yet.'))
                    : ListView.builder(
                      itemCount: sortedNotes.length,
                      itemBuilder: (context, idx) {
                        final note = sortedNotes[idx];
                        final originalIndex = sortedIndexes[idx];
                        final isSelected = _selectedIndexes.contains(
                          originalIndex,
                        );
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
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
                            leading: IconButton(
                              icon: Icon(
                                note.isFavourite
                                    ? Icons.star
                                    : Icons.star_border,
                                color:
                                    note.isFavourite
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                              tooltip:
                                  note.isFavourite
                                      ? 'Unmark Favourite'
                                      : 'Mark as Favourite',
                              onPressed: () {
                                _toggleFavourite(originalIndex);
                              },
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
                            onLongPress: () => _toggleSelect(originalIndex),
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelect(originalIndex);
                              } else {
                                _openNoteEditScreen(index: originalIndex);
                              }
                            },
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openNoteEditScreen(index: originalIndex);
                                } else if (value == 'favourite') {
                                  _toggleFavourite(originalIndex);
                                } else if (value == 'delete') {
                                  _deleteNote(originalIndex);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'favourite',
                                      child: ListTile(
                                        leading: Icon(
                                          note.isFavourite
                                              ? Icons.star
                                              : Icons.star_border,
                                          color:
                                              note.isFavourite
                                                  ? Colors.amber
                                                  : Colors.grey,
                                        ),
                                        title: Text(
                                          note.isFavourite
                                              ? 'Unmark Favourite'
                                              : 'Mark as Favourite',
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete'),
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          _isSelectionMode
              ? null
              : FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () => _openNoteEditScreen(),
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add),
                tooltip: 'Add Note',
              ),
    );
  }
}
