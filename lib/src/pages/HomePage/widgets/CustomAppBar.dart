import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UserPage.dart';
import '../Login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Usa el color de fondo del tema
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'APP',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'RENDE+',
            style: TextStyle(
              color: Color(0xFF36E58C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      leading: GestureDetector(
        onTap: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
            );
          }
        },
        child: const CircleAvatar(
          //backgroundImage: AssetImage('assets/user_image.png'), // habrá que cambiar por base de datos xd
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          color: Colors.white,
          onPressed: () {
            // hacer un widget de notificaciones waaa
          },
        )
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}