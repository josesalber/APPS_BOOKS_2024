import 'package:flutter/material.dart';

class AppStyles {
  static const BoxDecoration containerDecoration = BoxDecoration(
    color: Colors.white, // Asegúrate de que el color sea blanco
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black54,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  static const BoxDecoration searchFieldDecoration = BoxDecoration(
    color: Colors.white24,
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const BoxDecoration categoryFilterDecoration = BoxDecoration(
    color: Color(0xFF302f3c),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const BoxDecoration dropdownDecoration = BoxDecoration(
    color: Color(0xFF6c61af),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const BoxDecoration courseCardDecoration = BoxDecoration(
    color: Colors.white, // Asegúrate de que el color sea blanco
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const BoxDecoration courseCategoryDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const BoxDecoration courseDetailImageDecoration = BoxDecoration(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(15.0),
    ),
  );

  static const BoxDecoration courseDetailButtonDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00FFFFFF), Color(0xFF1c1a29)],
    ),
  );

  static const EdgeInsets containerPadding = EdgeInsets.all(16.0);
  static const EdgeInsets containerMargin = EdgeInsets.all(8.0);
  static const EdgeInsets searchFieldPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0);
  static const EdgeInsets courseCardPadding = EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0);
  static const EdgeInsets courseDetailPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
}