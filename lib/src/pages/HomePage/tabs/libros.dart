import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/app_styles.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/book_list.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/empty_state.dart';
import 'package:flutter_application_1/services/annas_archive_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibrosPage extends StatefulWidget {
  const LibrosPage({super.key});

  @override
  _LibrosPageState createState() => _LibrosPageState();
}

class _LibrosPageState extends State<LibrosPage> {
  List<dynamic> libros = [];
  TextEditingController searchController = TextEditingController();
  List<String> currentTopics = [];
  String selectedCategory = "Todos";
  List<String> categories = ["Todos"];
  String searchQuery = "";
  bool isLoading = false;

  final List<String> topics = [
    'programación',
    'ciencia ficción',
    'historia',
    'arte',
    'ciencia',
    'matemáticas',
    'literatura',
    'filosofía',
    'música',
    'deportes',
    'novelas',
    'comic',
    'magazine'
  ];

  final Map<String, String> categorySearchTerms = {
    'programación': 'programming, programación',
    'ciencia ficción': 'science fiction, ciencia ficción',
    'historia': 'history, historia',
    'arte': 'art, arte',
    'ciencia': 'science, ciencia',
    'matemáticas': 'mathematics, matemáticas',
    'literatura': 'literature, literatura',
    'filosofía': 'philosophy, filosofía',
    'música': 'music, música',
    'deportes': 'sports, deportes',
    'novelas': 'fiction, novelas',
    'comic': 'comic, cómic',
    'magazine': 'magazine, revista'
  };

  @override
  void initState() {
    super.initState();
    _checkAndUpdateBooks();
  }

  Future<void> _checkAndUpdateBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastUpdate');
    final now = DateTime.now();

    if (lastUpdate == null || now.difference(DateTime.parse(lastUpdate)).inHours >= 12) {
      _selectRandomTopics();
      await _fetchBooks();
      prefs.setString('lastUpdate', now.toIso8601String());
    } else {
      _selectRandomTopics();
      await _fetchBooks();
    }
  }

  void _selectRandomTopics() {
    final random = Random();
    currentTopics = List.generate(3, (_) => topics[random.nextInt(topics.length)]);
  }

  Future<void> _fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> allBooks = [];
    for (String topic in currentTopics) {
      final results = await AnnasArchiveApi.searchBooks(categorySearchTerms[topic] ?? topic);
      allBooks.addAll(results);
    }
    setState(() {
      libros = allBooks;
      categories = ["Todos"];
      categories.addAll(topics);
      isLoading = false;
    });
  }

  void _filterBooks() {
    setState(() {
      libros = libros.where((book) {
        final matchesCategory = selectedCategory == "Todos" || book['genre'] == selectedCategory || book['title'].toLowerCase().contains(selectedCategory.toLowerCase());
        final matchesSearch = book['title'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterBooksByCategory(String category) async {
    setState(() {
      selectedCategory = category;
    });
    if (category == "Todos" && searchController.text.isEmpty) {
      await _checkAndUpdateBooks();
    } else {
      await searchBooks();
    }
  }

  Future<void> searchBooks() async {
    setState(() {
      isLoading = true;
    });
    final query = searchController.text;
    String searchTerm;
    if (selectedCategory == "Todos") {
      searchTerm = query.isNotEmpty ? query : "";
    } else {
      searchTerm = query.isNotEmpty ? query : categorySearchTerms[selectedCategory] ?? selectedCategory;
    }
    final results = await AnnasArchiveApi.searchBooks(searchTerm, category: selectedCategory == "Todos" ? "all" : selectedCategory);
    setState(() {
      libros = results.where((book) {
        final matchesSearch = book['title'].toLowerCase().contains(query.toLowerCase());
        return matchesSearch;
      }).toList();
      isLoading = false;
    });
  }

  void _clearSearch() {
    searchController.clear();
    if (selectedCategory == "Todos") {
      _checkAndUpdateBooks();
    } else {
      searchBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _checkAndUpdateBooks,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : libros.isEmpty
                ? EmptyState(
                    selectedCategory: selectedCategory,
                    onClearFilters: () {
                      setState(() {
                        selectedCategory = "Todos";
                        _clearSearch();
                      });
                    },
                  )
                : BookList(libros: libros),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Padding(
          padding: AppStyles.searchFieldPadding,
          child: Column(
            children: [
              const Text(
                '📚 Libros Gratuitos 📖',
                style: TextStyles.title,
              ),
              const SizedBox(height: 10),
              _buildSearchField(),
              const SizedBox(height: 10),
              _buildCategoryFilter(),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Buscar libros...',
        labelStyle: TextStyles.searchField,
        filled: true,
        fillColor: AppStyles.searchFieldDecoration.color,
        border: OutlineInputBorder(
          borderRadius: AppStyles.searchFieldDecoration.borderRadius as BorderRadius,
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: _clearSearch,
        ),
      ),
      onSubmitted: (value) {
        searchQuery = value;
        if (value.isEmpty) {
          _clearSearch();
        } else {
          searchBooks();
        }
      },
    );
  }

  Container _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: AppStyles.categoryFilterDecoration,
      child: Row(
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: AppStyles.dropdownDecoration,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _filterBooksByCategory(value!);
                  },
                  dropdownColor: const Color(0xFF6c61af),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}