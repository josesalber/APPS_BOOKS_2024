import 'package:flutter/material.dart';

class Course {
  final String title;
  final String author;
  final String category;
  final String previewImage;
  final String couponUrl;
  final double rating;
  final DateTime expiredDate;
  final int students;
  final int contentLength;
  final String heading;
  final String description;

  Course({
    required this.title,
    required this.author,
    required this.category,
    required this.previewImage,
    required this.couponUrl,
    required this.rating,
    required this.expiredDate,
    required this.students,
    required this.contentLength,
    required this.heading,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'],
      author: json['author'],
      category: json['category'] ?? 'Unknown',
      previewImage: json['previewImage'] ?? '',
      couponUrl: json['couponUrl'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      expiredDate: DateTime.parse(json['expiredDate']),
      students: json['students'] ?? 0,
      contentLength: json['contentLength'] ?? 0,
      heading: json['heading'] ?? '',
      description: json['description'] ?? '',
    );
  }

  String getExpiryTime() {
    final now = DateTime.now();
    if (expiredDate.isBefore(now)) {
      return '';
    }
    final difference = expiredDate.difference(now);
    if (difference.inDays > 0) {
      return 'Expira en: ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Expira en: ${difference.inHours} horas';
    } else {
      return 'Expira en: ${difference.inMinutes} minutos';
    }
  }

  bool isExpired() {
    return expiredDate.isBefore(DateTime.now());
  }

  Color getCategoryColor() {
    switch (category) {
      case 'Development':
        return Colors.green;
      case 'Business':
        return const Color.fromARGB(255, 37, 37, 37);
      case 'Finance & Accounting':
        return Colors.brown;
      case 'IT & Software':
        return Colors.blue;
      case 'Office Productivity':
        return Colors.orange;
      case 'Personal Development':
        return Colors.purple;
      case 'Design':
        return Colors.red;
      case 'Marketing':
        return Colors.teal;
      case 'Lifestyle':
        return Colors.pink;
      case 'Photography & Video':
        return Colors.cyan;
      case 'Health & Fitness':
        return Colors.lime;
      case 'Music':
        return Colors.indigo;
      case 'Teaching & Academics':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  List<Widget> getRatingStars() {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.yellow, size: 16));
    }

    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.yellow, size: 16));
    }

    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.yellow, size: 16));
    }

    return stars;
  }
}