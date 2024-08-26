import 'package:flutter/material.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Esta es la página de Favoritos',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
