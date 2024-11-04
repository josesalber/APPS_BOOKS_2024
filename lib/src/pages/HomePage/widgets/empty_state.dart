import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/pages/HomePage/widgets/text_styles.dart';

class EmptyState extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onClearFilters;

  const EmptyState({
    super.key,
    required this.selectedCategory,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            selectedCategory == "Todos"
                ? 'El libro que buscas no está disponible :('
                : 'El libro que buscas no se encuentra en esta categoría :(',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onClearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 241, 241, 243),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Borrar Filtros',
              style: TextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}