import 'package:flutter/material.dart';

class NoteEditScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final bool isFavourite;
  final void Function(String title, String content, bool isFavourite) onSave;

  const NoteEditScreen({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.isFavourite = false,
    required this.onSave,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isFavourite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
    _isFavourite = widget.isFavourite;
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
    widget.onSave(title, content, _isFavourite);
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
          title: Text(widget.initialTitle == null ? 'Add Note' : 'Edit Note'),
          actions: [
            IconButton(
              icon: Icon(
                _isFavourite ? Icons.star : Icons.star_border,
                color: _isFavourite ? Colors.amber : Colors.white,
              ),
              tooltip: _isFavourite ? 'Unmark Favourite' : 'Mark as Favourite',
              onPressed: () {
                setState(() {
                  _isFavourite = !_isFavourite;
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
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
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
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _saveNoteAndPop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
