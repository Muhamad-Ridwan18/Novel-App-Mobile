// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';

class ChapterCreateScreen extends StatefulWidget {
  final int novelId;
  final ChapterElement? chapter; // Make chapter optional

  const ChapterCreateScreen({super.key, required this.novelId, this.chapter});

  @override
  // ignore: library_private_types_in_public_api
  _ChapterCreateScreenState createState() => _ChapterCreateScreenState();
}

class _ChapterCreateScreenState extends State<ChapterCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  late ChapterService _chapterService;

  @override
  void initState() {
    super.initState();
    _chapterService = ChapterService();

    // Set initial values if editing existing chapter
    if (widget.chapter != null) {
      _titleController.text = widget.chapter!.title;
      _contentController.text = widget.chapter!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveChapter() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      int chapterNumber = widget.chapter?.chapterNumber ?? 0;
      if (widget.chapter == null) {
        final List<ChapterElement> existingChapters = await _chapterService.fetchChaptersByNovelId(widget.novelId);
        chapterNumber = existingChapters.length + 1;
      }
      ChapterElement newChapter = ChapterElement(
        id: widget.chapter?.id ?? 0, // Use existing id if editing, otherwise default to 0
        novelId: widget.novelId,
        title: title,
        content: content,
        chapterNumber: chapterNumber, // Use existing number if editing, otherwise default to 0
        publishedDate: widget.chapter?.publishedDate ?? DateTime.now(), // Use existing date if editing, otherwise current date
        createdAt: widget.chapter?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.chapter != null) {
          // Update existing chapter
          await _chapterService.updateChapter(newChapter);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chapter updated successfully!')),
          );
        } else {
          // Create new chapter
          await _chapterService.createChapter(newChapter);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chapter created successfully!')),
          );
        }
        Navigator.of(context).pop(true); // Indicate success and pop screen
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save chapter. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter == null ? 'Create Chapter' : 'Edit Chapter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                _saveChapter();
              },
              child: const Text('Save Chapter'),
            ),
          ],
        ),
      ),
    );
  }
}
