import 'package:flutter/material.dart';

class SwitchButtons extends StatelessWidget {
  final bool showCourses;
  final Function(String) onSwitch;

  const SwitchButtons({
    super.key,
    required this.showCourses,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSwitchButton('Mis cursos', showCourses, true),
            _buildSwitchButton('Mi biblioteca', !showCourses, false),
          ],
        );
      },
    );
  }

  Widget _buildSwitchButton(String title, bool isSelected, bool isLeft) {
    return GestureDetector(
      onTap: () => onSwitch(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 109, 96, 175) : Colors.black54,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}