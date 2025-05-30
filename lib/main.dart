import 'package:flutter/material.dart';
import 'note_edit_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'recycle_bin_screen.dart';
import 'pinned_notes_screen.dart'; // Add this import

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

// Note model with title, content, pin flag, and cardColor
class Note {
  String title;
  String content;
  bool isPinned;
  Color cardColor;
  String? password; // Add this field

  Note({
    required this.title,
    required this.content,
    this.isPinned = false,
    this.cardColor = Colors.white,
    this.password, // Add this parameter
  });
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
    final note = isEditing ? _notes[index!] : null;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NoteEditScreen(
              initialTitle: note?.title,
              initialContent: note?.content,
              isPinned: note?.isPinned ?? false,
              initialColor: note?.cardColor ?? Colors.white,
              initialPassword: note?.password, // Pass password
              onSave: (title, content, isPinned, cardColor, password) {
                if (title.trim().isEmpty && content.trim().isEmpty) return;
                setState(() {
                  if (isEditing) {
                    _notes[index!] = Note(
                      title: title,
                      content: content,
                      isPinned: isPinned,
                      cardColor: cardColor,
                      password: password, // Save password
                    );
                  } else {
                    _notes.add(
                      Note(
                        title: title,
                        content: content,
                        isPinned: isPinned,
                        cardColor: cardColor,
                        password: password, // Save password
                      ),
                    );
                  }
                });
              },
            ),
      ),
    );
  }

  void _togglePin(int index) {
    setState(() {
      _notes[index].isPinned = !_notes[index].isPinned;
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

  void _togglePinSelected() {
    setState(() {
      for (final idx in _selectedIndexes) {
        _notes[idx].isPinned = !_notes[idx].isPinned;
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

  void _openPinnedNotesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PinnedNotesScreen(
              notes: _notes.where((n) => n.isPinned).toList(),
              onNoteTap: (note) {
                final index = _notes.indexOf(note);
                if (index != -1) {
                  _openNoteEditScreen(index: index);
                }
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pinned first, then others
    final sortedNotes = [
      ..._notes.where((n) => n.isPinned),
      ..._notes.where((n) => !n.isPinned),
    ];
    // Map sortedNotes to their original indexes for selection
    final sortedIndexes = [
      ..._notes
          .asMap()
          .entries
          .where((e) => e.value.isPinned)
          .map((e) => e.key),
      ..._notes
          .asMap()
          .entries
          .where((e) => !e.value.isPinned)
          .map((e) => e.key),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
                child: Text('Menu'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text(
                'Pinned Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _openPinnedNotesScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text(
                'Recycle Bin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _openRecycleBinScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _openSettingsScreen();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          child: Text(
            _isSelectionMode ? '${_selectedIndexes.length} selected' : 'Notes',
          ),
        ),
        centerTitle: true,
        actions:
            _isSelectionMode
                ? [
                  IconButton(
                    icon: Icon(
                      // If all selected notes are pinned, show unpin icon, else show pin icon
                      _selectedIndexes.isNotEmpty &&
                              _selectedIndexes.every(
                                (idx) => _notes[idx].isPinned,
                              )
                          ? Icons.push_pin_outlined
                          : Icons.push_pin,
                    ),
                    tooltip:
                        _selectedIndexes.isNotEmpty &&
                                _selectedIndexes.every(
                                  (idx) => _notes[idx].isPinned,
                                )
                            ? 'Unpin Selected'
                            : 'Pin Selected',
                    onPressed: _togglePinSelected,
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
                        return Card(
                          color: note.cardColor,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
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
                            trailing:
                                note.isPinned
                                    ? Icon(
                                      Icons.push_pin,
                                      color: Colors.deepPurple,
                                    )
                                    : null,
                            selected: isSelected,
                            onLongPress: () => _toggleSelect(originalIndex),
                            onTap: () async {
                              if (_isSelectionMode) {
                                _toggleSelect(originalIndex);
                              } else {
                                final note = _notes[originalIndex];
                                if (note.password != null &&
                                    note.password!.isNotEmpty) {
                                  final controller = TextEditingController();
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Enter Password'),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            maxLength: 4,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: '4-digit password',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (controller.text ==
                                                    note.password) {
                                                  Navigator.pop(context, true);
                                                }
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (result == true) {
                                    _openNoteEditScreen(index: originalIndex);
                                  }
                                } else {
                                  _openNoteEditScreen(index: originalIndex);
                                }
                              }
                            },
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
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
                tooltip: 'Add Note',
              ),
    );
  }
}
