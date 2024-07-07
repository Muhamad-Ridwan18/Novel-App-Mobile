// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../models/novel.dart';
import '../services/category_service.dart';
import '../services/tag_service.dart';
import '../services/novel_service.dart';
import 'novel_list_screen.dart';
import 'package:collection/collection.dart';

class NovelCreateScreen extends StatefulWidget {
  final NovelElement? novelToEdit;

  const NovelCreateScreen({super.key, this.novelToEdit});

  @override
  _NovelCreateScreenState createState() => _NovelCreateScreenState();
}

class _NovelCreateScreenState extends State<NovelCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverImageController;
  late TextEditingController _publishedDateController;
  late TextEditingController _synopsisController;
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<Tag> _selectedTags = [];
  List<Tag> _tags = [];
  bool _isLoading = false;
  int? _userId; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _coverImageController = TextEditingController();
    _publishedDateController = TextEditingController();
    _synopsisController = TextEditingController();
    _fetchCategories();
    _fetchTags();

    if (widget.novelToEdit != null) {
      _initializeForEdit();
    }

    _loadUserId();
  }

  void _initializeForEdit() {
    final novel = widget.novelToEdit!;
    _titleController.text = novel.title;
    _descriptionController.text = novel.description;
    _coverImageController.text = novel.coverImage;
    _publishedDateController.text =
        "${novel.publishedDate.year}-${novel.publishedDate.month.toString().padLeft(2, '0')}-${novel.publishedDate.day.toString().padLeft(2, '0')}";
    _synopsisController.text = novel.synopsis;
    _selectedCategory = _categories.firstWhereOrNull((cat) => cat.id == novel.categoryId);

    _selectedTags = List<Tag>.from(novel.tags);
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final categories = await CategoryService().fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error fetching categories
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchTags() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tags = await TagService().fetchTags();
      setState(() {
        _tags = tags;
      });
    } catch (e) {
      // Handle error fetching tags
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveNovel() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final novel = NovelElement(
        id: widget.novelToEdit?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        author: { 'id': _userId.toString() },
        categoryId: _selectedCategory!.id,
        coverImage: _coverImageController.text,
        publishedDate: DateTime.parse(_publishedDateController.text),
        synopsis: _synopsisController.text,
        createdAt: widget.novelToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _selectedTags,
      );

      try {
        if (widget.novelToEdit != null) {
          await NovelService().updateNovel(novel);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Novel updated successfully!')),
          );
        } else {
          await NovelService().createNovel(novel);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Novel created successfully!')),
          );
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NovelScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save novel: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form')),
      );
    }
  }


  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(widget.novelToEdit == null ? 'Create Novel' : 'Edit Novel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _coverImageController,
                        decoration: const InputDecoration(labelText: 'Cover Image URL'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the cover image URL';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _publishedDateController,
                        decoration: const InputDecoration(labelText: 'Published Date (YYYY-MM-DD)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the published date';
                          }
                          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                            return 'Please enter a valid date in the format YYYY-MM-DD';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _synopsisController,
                        decoration: const InputDecoration(labelText: 'Synopsis'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the synopsis';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: _categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      MultiSelectChip(
                        _tags,
                        onSelectionChanged: (selectedList) {
                          setState(() {
                            _selectedTags = selectedList;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveNovel,
                        child: Text(widget.novelToEdit == null ? 'Create Novel' : 'Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<Tag> tagList;
  final Function(List<Tag>) onSelectionChanged;

  const MultiSelectChip(this.tagList, {super.key, required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<Tag> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];
    for (var item in widget.tagList) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item.name),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
