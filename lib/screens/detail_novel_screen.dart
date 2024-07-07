// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/novel.dart';
import '../models/category.dart';
import '../services/chapter_service.dart';
import '../services/novel_service.dart';
import 'detail_chapter_screen.dart';
import 'create_chapter_screen.dart';
import 'create_novel_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovelDetailScreen extends StatefulWidget {
  final NovelElement novel;
  final Category? category;

  const NovelDetailScreen({super.key, required this.novel, this.category});

  @override
  _NovelDetailScreenState createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  late Future<List<ChapterElement>> futureChapters;
  late Future<NovelElement> futureNovel;
  final ChapterService _chapterService = ChapterService();
  final NovelService _novelService = NovelService();
  int? _userId;

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this novel?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _novelService.deleteNovel(widget.novel.id);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureChapters = _chapterService.fetchChaptersByNovelId(widget.novel.id);
    futureNovel = _novelService.fetchNovelById(widget.novel.id);
    _loadUserId();
  }

  void _reloadChapters() {
    setState(() {
      futureChapters = _chapterService.fetchChaptersByNovelId(widget.novel.id);
    });
  }

  void _showEditChapterScreen(ChapterElement chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterCreateScreen(
          novelId: widget.novel.id,
          chapter: chapter,
        ),
      ),
    ).then((chapterUpdated) {
      if (chapterUpdated == true) {
        _reloadChapters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          widget.novel.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.novel.author['id'] == _userId)
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelCreateScreen(
                      novelToEdit: widget.novel,
                    ),
                  ),
                );
              },
            ),
          if (widget.novel.author['id'] == _userId)
            IconButton(
              icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.network(
                      widget.novel.coverImage,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/cover-image.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.novel.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'By ${widget.novel.author['name']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 5),
                  if (widget.category != null)
                    Text(
                      'Category: ${widget.category!.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    widget.novel.synopsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chapters',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (widget.novel.author['id'] == _userId)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).dividerColor,
                          backgroundColor: Theme.of(context).highlightColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),

                          ),
                        ),
                        onPressed: () async {
                          bool? chapterCreated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChapterCreateScreen(novelId: widget.novel.id),
                            ),
                          );
                          if (chapterCreated == true) {
                            _reloadChapters();
                          }
                        }, 
                        child: const Text('Add Chapter')
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FutureBuilder<List<ChapterElement>>(
              future: futureChapters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No chapters available'));
                } else {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final chapter = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text('Chapter ${chapter.chapterNumber}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.novel.author['id'] == _userId)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditChapterScreen(chapter);
                                  },
                                ),
                              if (widget.novel.author['id'] == _userId)
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteChapterConfirmationDialog(chapter);
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterDetailScreen(
                                  chapter: chapter,
                                  chapters: snapshot.data!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChapterConfirmationDialog(ChapterElement chapter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this chapter?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _chapterService.deleteChapter(chapter.id);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close the dialog
                _reloadChapters(); // Reload chapter list
              },
            ),
          ],
        );
      },
    );
  }
}
