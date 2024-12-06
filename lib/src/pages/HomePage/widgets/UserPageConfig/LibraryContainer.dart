import 'package:flutter/material.dart';
import 'BookCard.dart';

class LibraryContainer extends StatefulWidget {
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
  _LibraryContainerState createState() => _LibraryContainerState();
}

class _LibraryContainerState extends State<LibraryContainer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
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
                    icon: Icon(widget.isSearching ? Icons.close : Icons.search, color: Colors.white),
                    onPressed: () {
                      widget.onSearch('');
                    },
                  ),
                ],
              ),
              if (widget.isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: widget.searchController,
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
                    onChanged: widget.onSearch,
                  ),
                ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = widget.filteredBooks[index];
                    return Dismissible(
                      key: Key(book['md5']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      onDismissed: (direction) async {
                        await widget.onRemove(book['md5']);
                        setState(() {
                          widget.filteredBooks.removeAt(index);
                        });
                      },
                      child: BookCard(
                        book: book,
                        onRemove: widget.onRemove,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}