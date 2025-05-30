import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // For SemanticsService
import 'package:flutter/services.dart'; // For HapticFeedback
import 'note_edit_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'recycle_bin_screen.dart';
import 'pinned_notes_screen.dart'; // Add this import
import 'locked_notes_screen.dart'; // Add this import
import 'app_drawer.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.light,
        cardColor: Colors.white,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.deepPurple,
          thickness: 0.8,
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.deepPurple,
          textColor: Colors.black,
        ),
        // Add highlight and splash color for dark mode consistency
        highlightColor: Colors.deepPurple.withOpacity(0.08),
        splashColor: Colors.deepPurple.withOpacity(0.12),
        // Add dialog and popup theme for dark mode
        dialogBackgroundColor: Colors.white,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          textStyle: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.dark,
        cardColor: const Color(0xFF222222),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF222222),
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.deepPurple,
          thickness: 0.8,
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.deepPurple,
          textColor: Colors.white,
        ),
        highlightColor: Colors.deepPurple.withOpacity(0.15),
        splashColor: Colors.deepPurple.withOpacity(0.18),
        dialogBackgroundColor: Color(0xFF222222),
        popupMenuTheme: const PopupMenuThemeData(
          color: Color(0xFF222222),
          textStyle: TextStyle(color: Colors.white),
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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool get _isSelectionMode => _selectedIndexes.isNotEmpty;

  // For accessibility: announce actions
  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Add focus node for accessibility
  final FocusNode _fabFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fabFocusNode.dispose();
    super.dispose();
  }

  void _openNoteEditScreen({int? index}) async {
    if (_isSelectionMode) return;
    final isEditing = index != null && index >= 0 && index < _notes.length;
    final note = isEditing ? _notes[index] : null;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NoteEditScreen(
              initialTitle: note?.title,
              initialContent: note?.content,
              isPinned: note?.isPinned ?? false,
              initialColor: note?.cardColor ?? Colors.white,
              initialPassword: note?.password,
              onSave: (title, content, isPinned, cardColor, password) {
                if (title.trim().isEmpty && content.trim().isEmpty) return;
                setState(() {
                  if (isEditing) {
                    _notes[index] = Note(
                      title: title,
                      content: content,
                      isPinned: isPinned,
                      cardColor: cardColor,
                      password: password,
                    );
                  } else {
                    _notes.add(
                      Note(
                        title: title,
                        content: content,
                        isPinned: isPinned,
                        cardColor: cardColor,
                        password: password,
                      ),
                    );
                    _listKey.currentState?.insertItem(_notes.length - 1);
                    HapticFeedback.lightImpact();
                    _announce('Note added');
                  }
                });
              },
              drawer: AppDrawer(
                onPinnedNotes: _openPinnedNotesScreen,
                onLockedNotes: _openLockedNotesScreen,
                onRecycleBin: _openRecycleBinScreen,
                onSettings: _openSettingsScreen,
              ),
            ),
      ),
    );
  }

  void _toggleSelect(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        HapticFeedback.selectionClick();
        _announce('Deselected');
      } else {
        _selectedIndexes.add(index);
        HapticFeedback.selectionClick();
        _announce('Selected');
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndexes.clear();
    });
    HapticFeedback.lightImpact();
    _announce('Selection cleared');
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
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notes deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                for (final idx in toRemove.reversed) {
                  final note = _recycleBin.removeLast();
                  _notes.insert(idx, note);
                }
              });
              _announce('Undo delete');
            },
            textColor: Colors.yellow,
          ),
        ),
      );
      _announce('Notes deleted');
    });
  }

  void _togglePinSelected() {
    setState(() {
      for (final idx in _selectedIndexes) {
        _notes[idx].isPinned = !_notes[idx].isPinned;
      }
      _selectedIndexes.clear();
      HapticFeedback.lightImpact();
      _announce('Pin status changed');
    });
  }

  void _openSettingsScreen() async {
    final result = await Navigator.of(context).push<ThemeMode>(
      MaterialPageRoute(
        builder:
            (context) => SettingsScreen(
              currentThemeMode: widget.themeMode ?? ThemeMode.light,
              drawer: AppDrawer(
                onPinnedNotes: _openPinnedNotesScreen,
                onLockedNotes: _openLockedNotesScreen,
                onRecycleBin: _openRecycleBinScreen,
                onSettings: _openSettingsScreen,
              ),
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
            (context) => RecycleBinScreen(
              deletedNotes: List<Note>.from(_recycleBin),
              drawer: AppDrawer(
                onPinnedNotes: _openPinnedNotesScreen,
                onLockedNotes: _openLockedNotesScreen,
                onRecycleBin: _openRecycleBinScreen,
                onSettings: _openSettingsScreen,
              ),
            ),
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
              drawer: AppDrawer(
                onPinnedNotes: _openPinnedNotesScreen,
                onLockedNotes: _openLockedNotesScreen,
                onRecycleBin: _openRecycleBinScreen,
                onSettings: _openSettingsScreen,
              ),
            ),
      ),
    );
  }

  void _openLockedNotesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => LockedNotesScreen(
              notes:
                  _notes
                      .where(
                        (n) => n.password != null && n.password!.isNotEmpty,
                      )
                      .toList(),
              onNoteTap: (note) async {
                final index = _notes.indexOf(note);
                if (index != -1) {
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
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (controller.text == note.password) {
                                  Navigator.pop(context, true);
                                }
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                  if (result == true) {
                    _openNoteEditScreen(index: index);
                  }
                }
              },
              drawer: AppDrawer(
                onPinnedNotes: _openPinnedNotesScreen,
                onLockedNotes: _openLockedNotesScreen,
                onRecycleBin: _openRecycleBinScreen,
                onSettings: _openSettingsScreen,
              ),
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
      drawer: AppDrawer(
        onPinnedNotes: _openPinnedNotesScreen,
        onLockedNotes: _openLockedNotesScreen,
        onRecycleBin: _openRecycleBinScreen,
        onSettings: _openSettingsScreen,
      ),
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
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder:
                (child, anim) => FadeTransition(opacity: anim, child: child),
            child: Text(
              _isSelectionMode
                  ? '${_selectedIndexes.length} selected'
                  : 'All Notes',
              key: ValueKey(_isSelectionMode ? 'selected' : 'all'),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions:
            _isSelectionMode
                ? null
                : [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search Notes',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => SearchScreen(
                                notes: _notes,
                                drawer: AppDrawer(
                                  onPinnedNotes: _openPinnedNotesScreen,
                                  onLockedNotes: _openLockedNotesScreen,
                                  onRecycleBin: _openRecycleBinScreen,
                                  onSettings: _openSettingsScreen,
                                ),
                              ),
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
                  sortedNotes.isEmpty
                      ? const Center(child: Text('No notes yet.'))
                      : RefreshIndicator(
                        onRefresh: () async {
                          HapticFeedback.lightImpact();
                          _announce('Refreshed');
                          setState(() {});
                        },
                        child: ListView.builder(
                          itemCount: sortedNotes.length,
                          itemBuilder: (context, idx) {
                            final note = sortedNotes[idx];
                            final originalIndex = sortedIndexes[idx];
                            final isSelected = _selectedIndexes.contains(
                              originalIndex,
                            );
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Card(
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
                                  title: GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                        ClipboardData(text: note.title),
                                      );
                                      HapticFeedback.heavyImpact();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Title copied to clipboard',
                                          ),
                                        ),
                                      );
                                      _announce('Title copied');
                                    },
                                    child: Tooltip(
                                      message: 'Long press to copy title',
                                      child: Text(
                                        note.title.isEmpty
                                            ? '(No Title)'
                                            : note.title,
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
                                    ),
                                  ),
                                  trailing:
                                      _isSelectionMode
                                          ? Checkbox(
                                            value: isSelected,
                                            onChanged:
                                                (_) => _toggleSelect(
                                                  originalIndex,
                                                ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            activeColor: Colors.deepPurple,
                                          )
                                          : (note.isPinned
                                              ? Tooltip(
                                                message: 'Pinned',
                                                child: Icon(
                                                  Icons.push_pin,
                                                  color: Colors.deepPurple,
                                                ),
                                              )
                                              : null),
                                  selected: isSelected,
                                  onLongPress:
                                      () => _toggleSelect(originalIndex),
                                  onTap: () async {
                                    if (_isSelectionMode) {
                                      _toggleSelect(originalIndex);
                                    } else {
                                      final note = _notes[originalIndex];
                                      if (note.password != null &&
                                          note.password!.isNotEmpty) {
                                        final controller =
                                            TextEditingController();
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Enter Password',
                                                ),
                                                content: TextField(
                                                  controller: controller,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 4,
                                                  obscureText: true,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText:
                                                            '4-digit password',
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
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                      } else {
                                                        HapticFeedback.heavyImpact();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Incorrect password',
                                                            ),
                                                          ),
                                                        );
                                                        _announce(
                                                          'Incorrect password',
                                                        );
                                                      }
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (result == true) {
                                          _openNoteEditScreen(
                                            index: originalIndex,
                                          );
                                        }
                                      } else {
                                        _openNoteEditScreen(
                                          index: originalIndex,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
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
                        _selectedIndexes.isNotEmpty &&
                                _selectedIndexes.every(
                                  (idx) => _notes[idx].isPinned,
                                )
                            ? Icons.push_pin_outlined
                            : Icons.push_pin,
                        color: Colors.deepPurple,
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
      floatingActionButton:
          _isSelectionMode
              ? null
              : Focus(
                focusNode: _fabFocusNode,
                child: Tooltip(
                  message: 'Add Note',
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _openNoteEditScreen();
                      _announce('Add note');
                    },
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    child: const Icon(Icons.add, size: 30),
                    tooltip: 'Add Note',
                  ),
                ),
              ),
    );
  }
}
