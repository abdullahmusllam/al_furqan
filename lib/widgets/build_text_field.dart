import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    ),
    readOnly: readOnly,
    validator: validator,
  );
}
