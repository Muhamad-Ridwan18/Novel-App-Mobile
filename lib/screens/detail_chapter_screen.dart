import 'package:flutter/material.dart';
import '../models/chapter.dart';

class ChapterDetailScreen extends StatelessWidget {
  final ChapterElement chapter;
  final List<ChapterElement> chapters; 

  const ChapterDetailScreen({super.key, required this.chapter, required this.chapters});

  @override
  Widget build(BuildContext context) {
    int currentIndex = chapters.indexWhere((element) => element.id == chapter.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${chapter.chapterNumber}'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.content, 
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).highlightColor,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailScreen(chapter: chapters[currentIndex - 1], chapters: chapters),
                        ),
                      );
                    },
                    child: const Text('Previous Chapter', style: TextStyle(color: Colors.white)),
                  ),
                if (currentIndex < chapters.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).highlightColor,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailScreen(chapter: chapters[currentIndex + 1], chapters: chapters),
                        ),
                      );
                    },
                    child: const Text(
                      'Next Chapter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      
    );
  }
}
