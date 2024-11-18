import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UserPage.dart';
import '../Login.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        child: user != null
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage('assets/user_image.png'),
                    );
                  }
                  if (snapshot.hasError) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage('assets/user_image.png'),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage('assets/user_image.png'),
                    );
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final profileImageUrl = data['profileImageId'] != null
                      ? 'https://fortnite-api.com/images/cosmetics/br/${data['profileImageId'].toLowerCase()}/icon.png'
                      : null;
                  return CircleAvatar(
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('assets/user_image.png') as ImageProvider,
                  );
                },
              )
            : const CircleAvatar(
                backgroundImage: AssetImage('assets/user_image.png'),
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
}