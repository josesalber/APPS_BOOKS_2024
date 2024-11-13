import 'package:flutter/material.dart';

class CategoryButtons extends StatelessWidget {
  final List<String> categories;

  const CategoryButtons({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Chip(
              label: Text(
                category,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }).toList(),
      ),
    );
  }
}