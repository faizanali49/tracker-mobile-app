import 'package:flutter/material.dart';

class CustomBtns extends StatelessWidget {
  final String text;
  const CustomBtns({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 16, 119, 244),
            Color.fromARGB(255, 18, 161, 238),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),

      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
