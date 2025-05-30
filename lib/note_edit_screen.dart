import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class NoteEditScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final bool isPinned;
  final Color? initialColor;
  final String? initialPassword; // Add this
  final void Function(
    String title,
    String content,
    bool isPinned,
    Color cardColor,
    String? password, // Add this
  )
  onSave;
  final Widget? drawer;

  const NoteEditScreen({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.isPinned = false,
    this.initialColor,
    this.initialPassword, // Add this
    required this.onSave,
    this.drawer,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isPinned;
  late Color _cardColor;
  late String? _password;

  final List<Color> _availableColors = [
    Colors.white,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.grey.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _isPinned = widget.isPinned;
    _cardColor = widget.initialColor ?? Colors.white;
    _password = widget.initialPassword;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showPasswordDialog() async {
    final controller = TextEditingController(text: _password ?? '');
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set 4-digit Password'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter 4-digit password',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isEmpty) {
                    Navigator.pop(context, null);
                  } else if (value.length == 4 && int.tryParse(value) != null) {
                    Navigator.pop(context, value);
                  }
                },
                child: const Text('Set'),
              ),
            ],
          ),
    );
    if (result != null || controller.text.isEmpty) {
      setState(() {
        _password = result;
      });
    }
  }

  void _removePassword() {
    setState(() {
      _password = null;
    });
  }

  void _saveNoteAndPop() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    widget.onSave(title, content, _isPinned, _cardColor, _password);
    Navigator.of(context).pop();
  }

  Future<void> _saveAsTxt() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final fileName = (title.isEmpty ? 'Untitled Note' : title) + '.txt';
    try {
      String? outputPath;
      if (!mounted) return;
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Note As',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (result != null) {
        outputPath = result;
        final file = File(outputPath);
        await file.writeAsString(
          'Title: ' + (title.isEmpty ? '(No Title)' : title) + '\n\n' + content,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Note saved as $fileName')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveNoteAndPop();
        return false;
      },
      child: Scaffold(
        drawer: widget.drawer,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saveNoteAndPop();
            },
          ),
          title: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: TextField(
              controller: _titleController,
              autofocus: widget.initialTitle == null,
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
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 28, color: Colors.white),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              offset: const Offset(0, 40),
              onSelected: (value) {
                switch (value) {
                  case 'pin':
                    setState(() {
                      _isPinned = !_isPinned;
                    });
                    break;
                  case 'set_password':
                    _showPasswordDialog();
                    break;
                  case 'remove_password':
                    _removePassword();
                    break;
                  case 'save':
                    _saveNoteAndPop();
                    break;
                  case 'save_txt':
                    _saveAsTxt();
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(
                            _isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isPinned ? 'Unpin Note' : 'Pin Note',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'set_password',
                      child: Row(
                        children: const [
                          Icon(Icons.lock, color: Colors.deepPurple),
                          SizedBox(width: 10),
                          Text(
                            'Set/Change Password',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    if (_password != null)
                      PopupMenuItem(
                        value: 'remove_password',
                        child: Row(
                          children: const [
                            Icon(Icons.lock_open, color: Colors.deepPurple),
                            SizedBox(width: 10),
                            Text(
                              'Remove Password',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: const [
                          Icon(Icons.save, color: Colors.deepPurple),
                          SizedBox(width: 10),
                          Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'save_txt',
                      child: Row(
                        children: const [
                          Icon(Icons.download, color: Colors.deepPurple),
                          SizedBox(width: 10),
                          Text(
                            'Save as .txt',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color picker row
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      _availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _cardColor = color;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    _cardColor == color
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                width: 2,
                              ),
                              boxShadow:
                                  _cardColor == color
                                      ? [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(
                                            0.2,
                                          ),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                      : [],
                            ),
                            child:
                                _cardColor == color
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.deepPurple,
                                      size: 18,
                                    )
                                    : null,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Type your note here...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onSubmitted: (_) => _saveNoteAndPop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
