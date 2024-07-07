// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../models/category.dart';
import '../services/novel_service.dart';
import '../services/category_service.dart';
import '../services/auth_service.dart';
import 'create_novel_screen.dart';
import 'detail_novel_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class NovelScreen extends StatefulWidget {
  const NovelScreen({super.key});

  @override
  _NovelScreenState createState() => _NovelScreenState();
}

class _NovelScreenState extends State<NovelScreen> {
  late Future<Novel> futureNovel;
  late Future<Novel> futureLastNovel;
  late Future<List<Category>> futureCategories;
  final NovelService _novelService = NovelService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService('http://10.0.2.2:8000/api');
  List<NovelElement> _allNovels = [];
  List<NovelElement> _filteredNovels = [];
  Map<int, Category> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    futureNovel = _novelService.fetchNovels().then((novelData) {
      setState(() {
        _allNovels = novelData.novels;
        _filteredNovels = _allNovels;
      });
      return novelData;
    });

    futureLastNovel = _novelService.fetchLastNovels().then((lastNovelData) {
      setState(() {
        _allNovels = lastNovelData.novels;
        _filteredNovels = _allNovels;
      });
      return lastNovelData;
    });

    futureCategories = _categoryService.fetchCategories().then((categories) {
      setState(() {
        _categoryMap = {for (var category in categories) category.id: category};
      });
      return categories;
    });
  }

  void _filterNovels(String query) {
    setState(() {
      _filteredNovels = _allNovels.where((novel) {
        return novel.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _navigateToDetailScreen(NovelElement novel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelDetailScreen(
          novel: novel,
          category: _categoryMap[novel.categoryId],
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novel', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.getThemeMode() == ThemeMode.light
            ? themeProvider.getLightTheme().appBarTheme. backgroundColor
            : themeProvider.getDarkTheme().appBarTheme.backgroundColor,
      ),
      body: Center(
        child: FutureBuilder<Novel>(
          future: futureNovel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          _filterNovels(value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search by title',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'New Novels',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    FutureBuilder<Novel>(
                      future: futureLastNovel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filteredNovels.length,
                              itemBuilder: (context, index) {
                                NovelElement novel = _filteredNovels[index];
                                Category? category = _categoryMap[novel.categoryId];
                                return InkWell(
                                  onTap: () => _navigateToDetailScreen(novel),
                                  child: Card(
                                    color: themeProvider.getThemeMode() == ThemeMode.light ? Colors.white : Colors.grey.shade900,
                                    margin: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 150,
                                      height: 290,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(5.0),
                                            child: AspectRatio(
                                              aspectRatio: 117 / 134,
                                              child: Image.network(
                                                novel.coverImage,
                                                width: 126,
                                                height: 174,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    'assets/cover-image.jpg',
                                                    width: 136,
                                                    height: 184,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              novel.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: themeProvider.getThemeMode() == ThemeMode.light
                                                    ? themeProvider.getLightTheme().textTheme.bodyLarge!.color
                                                    : themeProvider.getDarkTheme().textTheme.bodyMedium!.color,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              category?.name ?? 'Unknown',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Text('No data');
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'All Novels',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _filteredNovels.length,
                      itemBuilder: (context, index) {
                        NovelElement novel = _filteredNovels[index];
                        Category? category = _categoryMap[novel.categoryId];
                        // Map<String, dynamic> author = novel.author;
                        return InkWell(
                          onTap: () => _navigateToDetailScreen(novel),
                          child: Card(
                            color: themeProvider.getThemeMode() == ThemeMode.light ? Colors.white : Colors.grey.shade900,
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: AspectRatio(
                                  aspectRatio: 79 / 114,
                                  child: Image.network(
                                    novel.coverImage,
                                    width: 79,
                                    height: 114,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/cover-image.jpg',
                                        width: 79,
                                        height: 114,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              title: Text(
                                novel.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: themeProvider.getThemeMode() == ThemeMode.light
                                      ? themeProvider.getLightTheme().textTheme.bodyLarge!.color
                                      : themeProvider.getDarkTheme().textTheme.bodyLarge!.color,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(author['name']),
                                  if (category != null)
                                    Text(
                                      'Category : ${category.name}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.getThemeMode() == ThemeMode.light
                                            ? themeProvider.getLightTheme().textTheme.bodyLarge!.color
                                            : themeProvider.getDarkTheme().textTheme.bodyLarge!.color,
                                      )
                                    ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: novel.tags.map((tag) {
                                      return Chip(
                                        side: BorderSide(
                                          color: themeProvider.getThemeMode() == ThemeMode.light ? Colors.grey.shade500 : Colors.grey.shade800,
                                        ),
                                        backgroundColor: themeProvider.getThemeMode() == ThemeMode.light ? Colors.white : Colors.grey.shade800,
                                        label: Text(tag.name,
                                          style: TextStyle(
                                            color: themeProvider.getThemeMode() == ThemeMode.light
                                                ? themeProvider.getLightTheme().textTheme.bodyLarge!.color
                                                : themeProvider.getDarkTheme().textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              onTap: () => _navigateToDetailScreen(novel),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const Text('No data available');
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: themeProvider.getThemeMode() == ThemeMode.light ? Colors.blue : Colors.grey.shade900,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NovelScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NovelCreateScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NovelScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

