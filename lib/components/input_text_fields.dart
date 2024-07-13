import 'package:flutter/material.dart';

class ObscuredTextField extends StatelessWidget {
  final controller;
  final String labelText;
  final bool obsecureText;

  const ObscuredTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obsecureText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: controller,
        obscureText: obsecureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
      ),
    );
  }
}