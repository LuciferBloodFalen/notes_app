import 'package:flutter/material.dart';

class NoteEditScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final bool isPinned;
  final Color? initialColor;
  final void Function(
    String title,
    String content,
    bool isPinned,
    Color cardColor,
  )
  onSave;

  const NoteEditScreen({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.isPinned = false,
    this.initialColor,
    required this.onSave,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isPinned;
  late Color _cardColor;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNoteAndPop() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    widget.onSave(title, content, _isPinned, _cardColor);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveNoteAndPop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: DefaultTextStyle(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
            child: Text(widget.initialTitle == null ? 'Add Note' : 'Edit Note'),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? Colors.deepPurple : Colors.white,
              ),
              tooltip: _isPinned ? 'Unpin Note' : 'Pin Note',
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNoteAndPop,
              tooltip: 'Save',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Type your note here...',
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
