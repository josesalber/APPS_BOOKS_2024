import 'package:flutter/material.dart';
import 'BookCard.dart';

class LibraryContainer extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final List<Map<String, dynamic>> filteredBooks;
  final Function(String) onRemove;

  const LibraryContainer({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    required this.filteredBooks,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400, // Aumentar la altura de los cuadros
      child: Container(
        key: const ValueKey('library'),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Biblioteca',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
                  onPressed: () {
                    onSearch('');
                  },
                ),
              ],
            ),
            if (isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar libros...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: onSearch,
                ),
              ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return BookCard(
                    book: book,
                    onRemove: onRemove,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}