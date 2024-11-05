import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../text_styles.dart';

class ProfileCard extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? university;
  final String? email;

  const ProfileCard({
    super.key,
    this.firstName,
    this.lastName,
    this.university,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 109, 96, 175),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/user_image.png'), // Reemplaza con tu imagen
            radius: 30,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$firstName $lastName',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (university != null)
                Text(
                  university!,
                  style: const TextStyle(color: Colors.white70),
                ),
              Text(
                email ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}